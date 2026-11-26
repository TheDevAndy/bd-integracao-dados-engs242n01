-- 04_validacao
-- Nome:
-- Consultas de apoio à reunião de validação dos dados de FEVEREIRO/2025.
-- Escritas para PostgreSQL, sobre as tabelas do DDL corrigido
-- (sql/01_ddl_postgres.sql): produtos_filial(produto_id, descricao, idfornecedor),
-- fornecedor(idfornecedor, razao_social) e as demais como no enunciado.
--
-- Como usar na reunião:
--   1. Rode o bloco F (painel) primeiro: ele resume todas as verificações em
--      uma tela, com o total da base e o total de fevereiro.
--   2. Para cada linha do painel com valor > 0, rode a consulta detalhada
--      do mesmo código (B1, C3, ...) e mostre as linhas ao cliente.
--   3. O bloco E reúne verificações que devem retornar 0: servem para mostrar
--      ao cliente o que foi testado e está correto.
--
-- Convenção de "fevereiro": venda.data_emissao, pedido_compra.data_pedido e
-- entradas_mercadoria.data_entrada entre 01/02/2025 e 28/02/2025.
--
-- Vínculo pedido x entrada: entradas_mercadoria.ordem_compra =
-- pedido_compra.ordem_compra (e mesmo produto_id), conforme o enunciado.
-- pedido_compra.fornecedor_id é numérico (1, 2, ...) e fornecedor.idfornecedor
-- é texto ('F1', 'F2', ...): o vínculo é feito com 'F' || fornecedor_id.


-- =====================================================================
-- BLOCO A. COMPLETUDE E TOTAIS DE CONTROLE
-- =====================================================================

-- A1. Linhas por tabela: comparar com a planilha do cliente
--     (esperado: venda 33, pedido_compra 29, entradas_mercadoria 20,
--      produtos_filial 20, fornecedor 20).
SELECT 'venda' AS tabela, COUNT(*) AS linhas FROM venda
UNION ALL SELECT 'pedido_compra', COUNT(*) FROM pedido_compra
UNION ALL SELECT 'entradas_mercadoria', COUNT(*) FROM entradas_mercadoria
UNION ALL SELECT 'produtos_filial', COUNT(*) FROM produtos_filial
UNION ALL SELECT 'fornecedor', COUNT(*) FROM fornecedor;

-- A2. Totais de controle de fevereiro (vendas): o cliente confere com o
--     relatório do sistema dele. Valor = qtde_vendida * valor_unitario.
SELECT COUNT(*)                                                  AS linhas,
       COUNT(DISTINCT produto_id)                                AS produtos_distintos,
       ROUND(CAST(SUM(qtde_vendida) AS NUMERIC), 2)              AS qtde_total,
       ROUND(CAST(SUM(qtde_vendida * valor_unitario) AS NUMERIC), 2) AS valor_total_rs,
       MIN(data_emissao)                                         AS primeira_venda,
       MAX(data_emissao)                                         AS ultima_venda
FROM venda
WHERE data_emissao >= DATE '2025-02-01' AND data_emissao < DATE '2025-03-01';

-- A3. Calendário de fevereiro: dia a dia, incluindo dias SEM venda.
--     O cliente confirma se é esperado que só haja venda em alguns dias.
SELECT CAST(d AS DATE)                      AS dia,
       COUNT(v.venda_id)                    AS vendas,
       COALESCE(SUM(v.qtde_vendida), 0)     AS qtde
FROM generate_series(DATE '2025-02-01', DATE '2025-02-28', INTERVAL '1 day') AS d
LEFT JOIN venda v ON v.data_emissao = CAST(d AS DATE)
GROUP BY d
ORDER BY d;

-- A4. Fevereiro por filial: a filial confere o próprio total.
SELECT filial_id,
       COUNT(*)                                                  AS linhas,
       ROUND(CAST(SUM(qtde_vendida) AS NUMERIC), 2)              AS qtde_total,
       ROUND(CAST(SUM(qtde_vendida * valor_unitario) AS NUMERIC), 2) AS valor_total_rs
FROM venda
WHERE data_emissao >= DATE '2025-02-01' AND data_emissao < DATE '2025-03-01'
GROUP BY filial_id
ORDER BY filial_id;

-- A5. Fevereiro por produto, com indicação de cadastro (base da Parte 2).
--     Produtos "NÃO CADASTRADO" aparecem na venda mas não em produtos_filial.
SELECT v.produto_id,
       SUM(v.qtde_vendida)                                              AS qtde_total,
       ROUND(CAST(SUM(v.qtde_vendida * v.valor_unitario) AS NUMERIC), 2) AS valor_total_rs,
       CASE WHEN COUNT(p.produto_id) = 0 THEN 'NÃO CADASTRADO' ELSE 'ok' END AS cadastro
FROM venda v
LEFT JOIN produtos_filial p
       ON p.produto_id = v.produto_id AND p.filial_id = v.filial_id
WHERE v.data_emissao >= DATE '2025-02-01' AND v.data_emissao < DATE '2025-03-01'
GROUP BY v.produto_id
ORDER BY LENGTH(v.produto_id), v.produto_id;


-- =====================================================================
-- BLOCO B. VENDAS: INTEGRIDADE E CONSISTÊNCIA
-- =====================================================================

-- B1. Vendas de produto/filial sem cadastro em produtos_filial.
SELECT v.venda_id, v.data_emissao, v.filial_id, v.produto_id,
       v.qtde_vendida, v.valor_unitario,
       CASE WHEN v.data_emissao >= DATE '2025-02-01' AND v.data_emissao < DATE '2025-03-01'
            THEN 'sim' ELSE 'não' END AS em_fevereiro,
       CASE WHEN NOT EXISTS (SELECT 1 FROM produtos_filial x WHERE x.filial_id = v.filial_id)
            THEN 'filial sem nenhum produto cadastrado' ELSE 'filial ok' END AS situacao_filial
FROM venda v
LEFT JOIN produtos_filial p
       ON p.produto_id = v.produto_id AND p.filial_id = v.filial_id
WHERE p.produto_id IS NULL
ORDER BY v.data_emissao, v.venda_id;

-- B2. Quantidade fracionada em unidade "UN" (unidade não deveria ser fracionada).
SELECT venda_id, data_emissao, produto_id, qtde_vendida, unidade_medida
FROM venda
WHERE unidade_medida = 'UN' AND qtde_vendida <> FLOOR(qtde_vendida)
ORDER BY data_emissao, venda_id;

-- B3. Mesmo valor_unitario em produtos diferentes (sinal de linha copiada).
SELECT valor_unitario,
       COUNT(DISTINCT produto_id)                              AS qtd_produtos,
       STRING_AGG(DISTINCT produto_id, ', ' ORDER BY produto_id) AS produtos,
       COUNT(*)                                                AS linhas_de_venda
FROM venda
GROUP BY valor_unitario
HAVING COUNT(DISTINCT produto_id) > 1
ORDER BY valor_unitario;

-- B4. Preço praticado na venda x preco_venda do cadastro.
SELECT v.venda_id, v.data_emissao, v.produto_id,
       v.valor_unitario                                       AS preco_na_venda,
       p.preco_venda                                          AS preco_venda_cadastro,
       ROUND(CAST(v.valor_unitario - p.preco_venda AS NUMERIC), 2) AS diferenca
FROM venda v
JOIN produtos_filial p
  ON p.produto_id = v.produto_id AND p.filial_id = v.filial_id
WHERE ROUND(CAST(v.valor_unitario AS NUMERIC), 2) <> ROUND(CAST(p.preco_venda AS NUMERIC), 2)
ORDER BY v.data_emissao, v.venda_id;

-- B5. Horário das vendas: todas no mesmo horário indica valor padrão.
SELECT horariomov, COUNT(*) AS linhas
FROM venda
GROUP BY horariomov;


-- =====================================================================
-- BLOCO C. COMPRAS: PEDIDOS E ENTRADAS
-- =====================================================================

-- C1. Pedidos sem vínculo com entrada (ordem_compra = 0).
SELECT p.pedido_id, p.data_pedido, p.produto_id, p.qtde_pedida,
       p.qtde_entregue, p.qtde_pendente,
       EXISTS (SELECT 1 FROM entradas_mercadoria e
                WHERE e.ordem_compra = p.ordem_compra
                  AND e.produto_id = p.produto_id) AS tem_entrada
FROM pedido_compra p
WHERE p.ordem_compra = 0
ORDER BY p.pedido_id;

-- C2. Entradas de mercadoria sem pedido correspondente (órfãs).
SELECT e.nro_nfe, e.data_entrada, e.ordem_compra, e.produto_id,
       e.qtde_recebida, e.custo_unitario
FROM entradas_mercadoria e
LEFT JOIN pedido_compra p
       ON p.ordem_compra = e.ordem_compra AND p.produto_id = e.produto_id
WHERE p.pedido_id IS NULL
ORDER BY e.ordem_compra;

-- C3. Data de entrega prevista anterior à data do pedido.
SELECT pedido_id, produto_id, data_pedido, data_entrega,
       data_pedido - data_entrega AS dias_de_diferenca
FROM pedido_compra
WHERE data_entrega < data_pedido
ORDER BY data_pedido, pedido_id;

-- C4. Entrada de mercadoria anterior ao pedido.
SELECT p.pedido_id, p.produto_id, p.data_pedido, e.nro_nfe, e.data_entrada,
       p.data_pedido - e.data_entrada AS dias_de_diferenca
FROM pedido_compra p
JOIN entradas_mercadoria e
  ON e.ordem_compra = p.ordem_compra AND e.produto_id = p.produto_id
WHERE e.data_entrada < p.data_pedido
ORDER BY p.data_pedido, p.pedido_id;

-- C5. Quantidade recebida (entrada) x pedida e entregue (pedido).
SELECT p.pedido_id, p.produto_id,
       p.qtde_pedida, p.qtde_entregue, e.qtde_recebida,
       CASE WHEN e.qtde_recebida > p.qtde_pedida THEN 'sim' ELSE 'não' END AS recebida_maior_que_pedida,
       e.qtde_recebida - p.qtde_entregue                                   AS recebida_menos_entregue
FROM pedido_compra p
JOIN entradas_mercadoria e
  ON e.ordem_compra = p.ordem_compra AND e.produto_id = p.produto_id
WHERE e.qtde_recebida <> p.qtde_entregue OR e.qtde_recebida > p.qtde_pedida
ORDER BY p.pedido_id;

-- C6. Preço de compra do pedido x custo da entrada.
SELECT p.pedido_id, p.produto_id,
       p.preco_compra                                   AS preco_pedido,
       e.custo_unitario                                 AS custo_entrada,
       ROUND(CAST(e.custo_unitario - p.preco_compra AS NUMERIC), 2) AS diferenca
FROM pedido_compra p
JOIN entradas_mercadoria e
  ON e.ordem_compra = p.ordem_compra AND e.produto_id = p.produto_id
WHERE ROUND(CAST(p.preco_compra AS NUMERIC), 2) <> ROUND(CAST(e.custo_unitario AS NUMERIC), 2)
ORDER BY p.pedido_id;

-- C7. Mesmo produto/filial em mais de um pedido (possível duplicidade).
SELECT produto_id, filial_id,
       COUNT(*)                                   AS linhas_de_pedido,
       STRING_AGG(CAST(CAST(pedido_id AS INT) AS TEXT), ', ' ORDER BY pedido_id) AS pedidos
FROM pedido_compra
GROUP BY produto_id, filial_id
HAVING COUNT(*) > 1
ORDER BY LENGTH(produto_id), produto_id;


-- =====================================================================
-- BLOCO D. CADASTROS: PRODUTOS E FORNECEDORES
-- =====================================================================

-- D1. Preço de venda menor que preço de compra (margem negativa).
SELECT produto_id, descricao, preco_compra, preco_venda,
       ROUND(CAST(preco_venda - preco_compra AS NUMERIC), 2) AS margem_unitaria
FROM produtos_filial
WHERE preco_venda < preco_compra
ORDER BY margem_unitaria;

-- D2. Fornecedor do pedido diferente do fornecedor do cadastro do produto.
SELECT p.pedido_id, p.produto_id,
       'F' || CAST(p.fornecedor_id AS TEXT) AS fornecedor_no_pedido,
       f.idfornecedor                       AS fornecedor_no_cadastro
FROM pedido_compra p
JOIN produtos_filial f
  ON f.produto_id = p.produto_id AND f.filial_id = p.filial_id
WHERE 'F' || CAST(p.fornecedor_id AS TEXT) <> f.idfornecedor
ORDER BY p.pedido_id;

-- D3. Fornecedores cadastrados sem nenhum produto.
SELECT fo.idfornecedor, fo.razao_social
FROM fornecedor fo
WHERE NOT EXISTS (SELECT 1 FROM produtos_filial p WHERE p.idfornecedor = fo.idfornecedor)
ORDER BY LENGTH(fo.idfornecedor), fo.idfornecedor;

-- D4. Preços do cadastro: preco_unitario x preco_venda x preco_compra.
--     O cliente explica o que cada campo significa.
SELECT produto_id, preco_unitario, preco_compra, preco_venda
FROM produtos_filial
WHERE ROUND(CAST(preco_unitario AS NUMERIC), 2) <> ROUND(CAST(preco_venda AS NUMERIC), 2)
ORDER BY LENGTH(produto_id), produto_id;

-- D5. Vendas de fevereiro maiores que o estoque cadastrado.
SELECT v.produto_id, SUM(v.qtde_vendida) AS vendido_em_fevereiro, p.estoque
FROM venda v
JOIN produtos_filial p
  ON p.produto_id = v.produto_id AND p.filial_id = v.filial_id
WHERE v.data_emissao >= DATE '2025-02-01' AND v.data_emissao < DATE '2025-03-01'
GROUP BY v.produto_id, p.estoque
HAVING SUM(v.qtde_vendida) > p.estoque;


-- =====================================================================
-- BLOCO E. VERIFICAÇÕES QUE DEVEM RETORNAR 0 (o que está correto)
-- =====================================================================
SELECT 'Notas fiscais (nro_nfe) repetidas' AS verificacao, COUNT(*) AS problemas
FROM (SELECT nro_nfe FROM entradas_mercadoria GROUP BY nro_nfe HAVING COUNT(*) > 1) t
UNION ALL
SELECT 'Pedidos com qtde_entregue maior que qtde_pedida',
       COUNT(*) FROM pedido_compra WHERE qtde_entregue > qtde_pedida
UNION ALL
SELECT 'qtde_pendente diferente de pedida - entregue',
       COUNT(*) FROM pedido_compra WHERE qtde_pendente <> qtde_pedida - qtde_entregue
UNION ALL
SELECT 'Vendas com quantidade nula ou menor/igual a zero',
       COUNT(*) FROM venda WHERE qtde_vendida IS NULL OR qtde_vendida <= 0
UNION ALL
SELECT 'Vendas com valor_unitario menor ou igual a zero',
       COUNT(*) FROM venda WHERE valor_unitario <= 0
UNION ALL
SELECT 'Produtos com estoque negativo ou nulo',
       COUNT(*) FROM produtos_filial WHERE estoque IS NULL OR estoque < 0
UNION ALL
SELECT 'Descrição do produto diferente entre pedido e cadastro',
       COUNT(*) FROM pedido_compra p
       JOIN produtos_filial f ON f.produto_id = p.produto_id AND f.filial_id = p.filial_id
       WHERE p.descricao_produto <> f.descricao
UNION ALL
SELECT 'Pedidos com fornecedor inexistente no cadastro de fornecedores',
       COUNT(*) FROM pedido_compra p
       WHERE NOT EXISTS (SELECT 1 FROM fornecedor fo WHERE fo.idfornecedor = 'F' || CAST(p.fornecedor_id AS TEXT))
UNION ALL
SELECT 'Produtos com fornecedor inexistente no cadastro de fornecedores',
       COUNT(*) FROM produtos_filial p
       WHERE NOT EXISTS (SELECT 1 FROM fornecedor fo WHERE fo.idfornecedor = p.idfornecedor)
UNION ALL
SELECT 'Entradas com produto fora do cadastro de produtos',
       COUNT(*) FROM entradas_mercadoria e
       WHERE NOT EXISTS (SELECT 1 FROM produtos_filial p
                          WHERE p.produto_id = e.produto_id AND p.filial_id = e.filial_id)
UNION ALL
SELECT 'Pedidos com produto fora do cadastro de produtos',
       COUNT(*) FROM pedido_compra p
       WHERE NOT EXISTS (SELECT 1 FROM produtos_filial f
                          WHERE f.produto_id = p.produto_id AND f.filial_id = p.filial_id);


-- =====================================================================
-- BLOCO F. PAINEL RESUMO (rodar primeiro na reunião)
-- Colunas: total na base e quantos desses são de fevereiro/2025.
-- =====================================================================
SELECT 'B1' AS codigo, 'Vendas de produto/filial sem cadastro' AS verificacao,
       COUNT(*) AS total_na_base,
       COALESCE(SUM(CASE WHEN v.data_emissao >= DATE '2025-02-01' AND v.data_emissao < DATE '2025-03-01' THEN 1 ELSE 0 END), 0) AS em_fevereiro
FROM venda v
LEFT JOIN produtos_filial p ON p.produto_id = v.produto_id AND p.filial_id = v.filial_id
WHERE p.produto_id IS NULL
UNION ALL
SELECT 'B2', 'Quantidade fracionada em UN',
       COUNT(*),
       COALESCE(SUM(CASE WHEN data_emissao >= DATE '2025-02-01' AND data_emissao < DATE '2025-03-01' THEN 1 ELSE 0 END), 0)
FROM venda WHERE unidade_medida = 'UN' AND qtde_vendida <> FLOOR(qtde_vendida)
UNION ALL
SELECT 'B3', 'Vendas com valor_unitario repetido entre produtos diferentes',
       COUNT(*),
       COALESCE(SUM(CASE WHEN data_emissao >= DATE '2025-02-01' AND data_emissao < DATE '2025-03-01' THEN 1 ELSE 0 END), 0)
FROM venda
WHERE valor_unitario IN (SELECT valor_unitario FROM venda GROUP BY valor_unitario HAVING COUNT(DISTINCT produto_id) > 1)
UNION ALL
SELECT 'B4', 'Preço da venda diferente do preco_venda do cadastro',
       COUNT(*),
       COALESCE(SUM(CASE WHEN v.data_emissao >= DATE '2025-02-01' AND v.data_emissao < DATE '2025-03-01' THEN 1 ELSE 0 END), 0)
FROM venda v
JOIN produtos_filial p ON p.produto_id = v.produto_id AND p.filial_id = v.filial_id
WHERE ROUND(CAST(v.valor_unitario AS NUMERIC), 2) <> ROUND(CAST(p.preco_venda AS NUMERIC), 2)
UNION ALL
SELECT 'B5', 'Vendas com horário padrão 08:00:00',
       COUNT(*),
       COALESCE(SUM(CASE WHEN data_emissao >= DATE '2025-02-01' AND data_emissao < DATE '2025-03-01' THEN 1 ELSE 0 END), 0)
FROM venda WHERE horariomov = '08:00:00'
UNION ALL
SELECT 'C1', 'Pedidos sem vínculo com entrada (ordem_compra = 0)',
       COUNT(*),
       COALESCE(SUM(CASE WHEN data_pedido >= DATE '2025-02-01' AND data_pedido < DATE '2025-03-01' THEN 1 ELSE 0 END), 0)
FROM pedido_compra WHERE ordem_compra = 0
UNION ALL
SELECT 'C2', 'Entradas sem pedido correspondente',
       COUNT(*),
       COALESCE(SUM(CASE WHEN e.data_entrada >= DATE '2025-02-01' AND e.data_entrada < DATE '2025-03-01' THEN 1 ELSE 0 END), 0)
FROM entradas_mercadoria e
LEFT JOIN pedido_compra p ON p.ordem_compra = e.ordem_compra AND p.produto_id = e.produto_id
WHERE p.pedido_id IS NULL
UNION ALL
SELECT 'C3', 'Data de entrega anterior à data do pedido',
       COUNT(*),
       COALESCE(SUM(CASE WHEN data_pedido >= DATE '2025-02-01' AND data_pedido < DATE '2025-03-01' THEN 1 ELSE 0 END), 0)
FROM pedido_compra WHERE data_entrega < data_pedido
UNION ALL
SELECT 'C4', 'Entrada anterior ao pedido',
       COUNT(*),
       COALESCE(SUM(CASE WHEN p.data_pedido >= DATE '2025-02-01' AND p.data_pedido < DATE '2025-03-01' THEN 1 ELSE 0 END), 0)
FROM pedido_compra p
JOIN entradas_mercadoria e ON e.ordem_compra = p.ordem_compra AND e.produto_id = p.produto_id
WHERE e.data_entrada < p.data_pedido
UNION ALL
SELECT 'C5a', 'Quantidade recebida maior que a pedida',
       COUNT(*),
       COALESCE(SUM(CASE WHEN p.data_pedido >= DATE '2025-02-01' AND p.data_pedido < DATE '2025-03-01' THEN 1 ELSE 0 END), 0)
FROM pedido_compra p
JOIN entradas_mercadoria e ON e.ordem_compra = p.ordem_compra AND e.produto_id = p.produto_id
WHERE e.qtde_recebida > p.qtde_pedida
UNION ALL
SELECT 'C5b', 'Quantidade recebida diferente da entregue no pedido',
       COUNT(*),
       COALESCE(SUM(CASE WHEN p.data_pedido >= DATE '2025-02-01' AND p.data_pedido < DATE '2025-03-01' THEN 1 ELSE 0 END), 0)
FROM pedido_compra p
JOIN entradas_mercadoria e ON e.ordem_compra = p.ordem_compra AND e.produto_id = p.produto_id
WHERE e.qtde_recebida <> p.qtde_entregue
UNION ALL
SELECT 'C6', 'Preço do pedido diferente do custo da entrada',
       COUNT(*),
       COALESCE(SUM(CASE WHEN p.data_pedido >= DATE '2025-02-01' AND p.data_pedido < DATE '2025-03-01' THEN 1 ELSE 0 END), 0)
FROM pedido_compra p
JOIN entradas_mercadoria e ON e.ordem_compra = p.ordem_compra AND e.produto_id = p.produto_id
WHERE ROUND(CAST(p.preco_compra AS NUMERIC), 2) <> ROUND(CAST(e.custo_unitario AS NUMERIC), 2)
UNION ALL
SELECT 'C7', 'Linhas de pedido em produto/filial repetido',
       COUNT(*),
       COALESCE(SUM(CASE WHEN p.data_pedido >= DATE '2025-02-01' AND p.data_pedido < DATE '2025-03-01' THEN 1 ELSE 0 END), 0)
FROM pedido_compra p
WHERE (p.produto_id, p.filial_id) IN
      (SELECT produto_id, filial_id FROM pedido_compra GROUP BY produto_id, filial_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'D1', 'Produtos com preço de venda menor que o de compra',
       COUNT(*), CAST(NULL AS BIGINT)
FROM produtos_filial WHERE preco_venda < preco_compra
UNION ALL
SELECT 'D2', 'Pedidos com fornecedor diferente do cadastro do produto',
       COUNT(*),
       COALESCE(SUM(CASE WHEN p.data_pedido >= DATE '2025-02-01' AND p.data_pedido < DATE '2025-03-01' THEN 1 ELSE 0 END), 0)
FROM pedido_compra p
JOIN produtos_filial f ON f.produto_id = p.produto_id AND f.filial_id = p.filial_id
WHERE 'F' || CAST(p.fornecedor_id AS TEXT) <> f.idfornecedor
UNION ALL
SELECT 'D3', 'Fornecedores sem nenhum produto',
       COUNT(*), CAST(NULL AS BIGINT)
FROM fornecedor fo
WHERE NOT EXISTS (SELECT 1 FROM produtos_filial p WHERE p.idfornecedor = fo.idfornecedor)
UNION ALL
SELECT 'D4', 'Produtos com preco_unitario diferente de preco_venda',
       COUNT(*), CAST(NULL AS BIGINT)
FROM produtos_filial
WHERE ROUND(CAST(preco_unitario AS NUMERIC), 2) <> ROUND(CAST(preco_venda AS NUMERIC), 2)
UNION ALL
SELECT 'D5', 'Produtos vendidos em fevereiro acima do estoque cadastrado',
       COUNT(*), CAST(NULL AS BIGINT)
FROM (SELECT v.produto_id
        FROM venda v
        JOIN produtos_filial p ON p.produto_id = v.produto_id AND p.filial_id = v.filial_id
       WHERE v.data_emissao >= DATE '2025-02-01' AND v.data_emissao < DATE '2025-03-01'
       GROUP BY v.produto_id, p.estoque
      HAVING SUM(v.qtde_vendida) > p.estoque) t
ORDER BY 1;

