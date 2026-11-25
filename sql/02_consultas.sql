-- 02_consultas
-- Nome: Consumo por produto e mês
SELECT
    produto_id,
    SUM(qtde_vendida) AS quantidade_total,
    SUM(qtde_vendida * valor_unitario) AS valor_total
FROM public.venda
WHERE data_emissao >= DATE '2025-02-01'
  AND data_emissao < DATE '2025-03-01'
GROUP BY produto_id
ORDER BY produto_id;

-- Nome: Produtos com requisição pendente
SELECT
    pc.pedido_id,
    pc.produto_id,
    p.descricao,
    pc.qtde_pedida,
    pc.qtde_entregue,
    pc.qtde_pendente,
    pc.data_pedido
FROM public.pedido_compra AS pc
INNER JOIN public.produtos_filial AS p
    ON pc.produto_id = p.produto_id
    AND pc.filial_id = p.filial_id
WHERE pc.qtde_pendente > 0
ORDER BY pc.data_pedido;
