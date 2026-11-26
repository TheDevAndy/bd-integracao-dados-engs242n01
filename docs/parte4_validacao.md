# Parte 4: Roteiro de validação com o cliente (fevereiro/2025)

Este roteiro serve para a reunião final de validação dos dados de fevereiro/2025. O objetivo é que o cliente saia da reunião sabendo (a) quais números estão confirmados, (b) quais problemas existem na base original dele e (c) quais decisões dependem dele. As consultas citadas (A1, B1, C3 ...) estão em `sql/04_validacao.sql`.

Convenção de "fevereiro": `venda.data_emissao`, `pedido_compra.data_pedido` e `entradas_mercadoria.data_entrada` entre 01/02/2025 e 28/02/2025.

## 1. Pontos a validar

### 1.1 Abertura: escopo e completude
- Confirmar o período (fevereiro/2025), as filiais e as tabelas que fazem parte da validação.
- Conferir que nada se perdeu na importação: 33 vendas, 29 pedidos, 20 entradas, 20 produtos e 20 fornecedores, iguais à planilha (consulta A1).

### 1.2 Totais de fevereiro (o cliente compara com o sistema dele)
- Vendas de fevereiro: 14 linhas, 14 produtos, 173,22 unidades e R$ 14.093,17 (A2).
- Por filial: filial 1 com 13 linhas e R$ 13.545,64; filial 2 com 1 linha e R$ 547,53 (A4).
- Dia a dia (A3): só 6 dos 28 dias de fevereiro têm venda (07, 17, 18, 20, 22 e 28). Perguntar se isso é esperado ou se faltam dias na extração.
- Por produto (A5): mostra quais produtos vendidos não têm cadastro. Das 14 linhas, 6 (R$ 3.241,24, cerca de 23% do valor do mês) são de produtos que não existem no cadastro.

### 1.3 Cadastros (produtos, filiais, fornecedores)
- Produtos P21 a P28 aparecem nas vendas, mas não em `produtos_filial` (B1). Perguntar se são produtos novos que faltam no cadastro ou lançamentos indevidos.
- O cadastro só tem a filial 1. As vendas das filiais 2 e 3 (P27 em fevereiro, P28 e P27 em março) não têm produtos cadastrados. Perguntar se as filiais 2 e 3 existem e vendem esses itens.
- O fornecedor informado no pedido é diferente do fornecedor do cadastro do produto em 22 dos 29 pedidos (D2). Perguntar qual é a fonte correta.
- Os fornecedores F14, F15 e F16 não têm produto associado (D3).

### 1.4 Regras de negócio que só o cliente conhece
- Unidade "UN" com quantidade fracionada (38,60; 20,04; 2,86; 37,11; 3,11): é erro de digitação ou a unidade deveria ser outra, como kg ou litro? (B2).
- Preço da venda diferente do `preco_venda` do cadastro em todas as 20 vendas que têm cadastro (B4), e `preco_unitario` diferente de `preco_venda` em todos os 20 produtos (D4). Perguntar o significado de cada campo de preço e qual vale.
- Quatro produtos (P1, P8, P15 e P18) têm preço de venda menor que o de compra (D1). Pode ser promoção ou erro de cadastro.
- P14 vendeu 53 unidades em fevereiro e o estoque cadastrado é 9 (D5). Perguntar se o estoque é uma foto de data diferente.
- Todas as 33 vendas têm horário 08:00:00 (B5). Perguntar se o horário é real ou preenchido por padrão.
- Vários valores unitários se repetem entre produtos diferentes: as vendas 21 a 28 reaproveitam os preços das vendas 13 a 20 (B3). Perguntar se são cópias.

### 1.5 Ciclo de compras (pedido e entrada)
- Pedidos 19 a 29 estão com `ordem_compra = 0`, ou seja, sem vínculo com entrada (C1). Já as entradas NFE19 e NFE20 (ordens 19 e 20) ficam sem pedido (C2), o que sugere que os pedidos 19 e 20 deveriam ter essas ordens. Perguntar se a ordem de compra deveria ser preenchida.
- Os pedidos 21 a 29 repetem os produtos P12 a P20 dos pedidos 12 a 20 (C7). Perguntar se são reposições reais ou duplicidade.
- Datas incoerentes: entrega prevista antes do pedido (C3) e entrada de mercadoria antes do pedido (C4).
- Quantidades incoerentes: recebida maior que a pedida (C5) e recebida diferente da entregue registrada no pedido (C5).
- Preço do pedido diferente do custo da entrada em todas as 18 entradas com pedido (C6).

### 1.6 Fechamento
- Para cada ponto acima, registrar a decisão do cliente: corrigir na origem, aceitar como está ou excluir do escopo. A decisão e o responsável vão para uma ata.

## 2. Técnicas para garantir exatidão e precisão
- **Reconciliação por totais de controle.** Contagem de linhas e somas (quantidade e valor) por tabela, por filial e por dia, para o cliente comparar com o sistema dele (A1 a A5). Totais que batem dão segurança de que a importação não perdeu nem duplicou dados.
- **Conferência dupla da importação.** Comparar a contagem de linhas da planilha com a do banco e, se possível, importar por duas vias (script e DBeaver) e comparar os resultados.
- **Integridade referencial.** Procurar linhas "órfãs": vendas sem produto, entradas sem pedido, pedidos sem entrada, produtos sem fornecedor (B1, C1, C2, D2, D3 e o bloco E).
- **Regras de consistência entre tabelas.** Datas na ordem lógica (pedido, entrega, entrada), quantidades recebidas compatíveis com as pedidas, preço do pedido igual ao custo da entrada (C3 a C6).
- **Regras de domínio.** Unidade de medida compatível com a quantidade, valores positivos, preço de venda maior que o de compra (B2, D1 e bloco E).
- **Detecção de duplicidade e de dado copiado.** Mesma chave de negócio em mais de uma linha e valores repetidos entre produtos diferentes (B3, C7).
- **Conferência manual por amostragem.** Como fevereiro tem só 14 vendas, 17 pedidos e 10 entradas, a conferência pode ser de 100% das linhas, lado a lado com o documento de origem do cliente. Em bases maiores, usar amostra dos maiores valores e das linhas sinalizadas.
- **Precisão numérica.** Valores monetários em `numeric` e arredondamento explícito (`ROUND(CAST(... AS NUMERIC), 2)`) nas consultas. A soma em `float8` gera resíduos como 173,22000000000003, que não podem aparecer para o cliente.
- **Testes que devem retornar zero.** O bloco E mostra ao cliente o que foi testado e está correto: nenhuma nota fiscal repetida, nenhuma quantidade nula, nenhum estoque negativo, descrições iguais entre pedido e cadastro.
- **Repetibilidade.** As consultas ficam salvas e são reexecutadas após cada correção. O painel (bloco F) deve mostrar os problemas diminuindo até chegar ao que o cliente decidiu aceitar.
- **Rastreabilidade.** Cada erro é registrado com a consulta que o mostra, para o cliente ver as linhas exatas e não só um número.

## 3. Consultas preparadas para a reunião

As consultas ficam em `sql/04_validacao.sql`. Ordem sugerida na reunião: F (painel), depois o detalhe de cada linha do painel, por fim E (o que está correto).

| Código | O que mostra |
| --- | --- |
| A1 | Linhas por tabela, para comparar com a planilha. |
| A2 | Totais de controle de fevereiro (linhas, produtos, quantidade, valor, primeira e última venda). |
| A3 | Vendas dia a dia, incluindo os dias sem venda. |
| A4 | Totais de fevereiro por filial. |
| A5 | Totais por produto, com marca de "NÃO CADASTRADO". |
| B1 | Vendas de produto ou filial sem cadastro. |
| B2 | Quantidade fracionada em unidade "UN". |
| B3 | Mesmo valor unitário em produtos diferentes. |
| B4 | Preço da venda x `preco_venda` do cadastro. |
| B5 | Horários das vendas (todos iguais). |
| C1 | Pedidos com `ordem_compra = 0`. |
| C2 | Entradas sem pedido correspondente. |
| C3 | Entrega prevista anterior ao pedido. |
| C4 | Entrada anterior ao pedido. |
| C5 | Quantidade recebida x pedida x entregue. |
| C6 | Preço do pedido x custo da entrada. |
| C7 | Produto repetido em mais de um pedido. |
| D1 | Produtos com preço de venda menor que o de compra. |
| D2 | Fornecedor do pedido diferente do fornecedor do cadastro. |
| D3 | Fornecedores sem produto. |
| D4 | Preços do cadastro (`preco_unitario`, `preco_compra`, `preco_venda`). |
| D5 | Vendas de fevereiro acima do estoque. |
| E | Verificações que devem retornar 0 (o que está correto). |
| F | Painel resumo com o total da base e o total de fevereiro de cada verificação. |


(As consultas ficam em `sql/04_validacao.sql`. Explique aqui o que cada uma mostra.)

## Erros encontrados nos dados

A coluna Quantidade mostra o total na base e, entre parênteses, quanto é de fevereiro/2025 (quando a data permite separar).

| Tabela | Problema | Quantidade | Consulta que mostra |
| --- | --- | --- | --- |
| venda | Venda de produto sem cadastro em `produtos_filial` (P21 a P28) | 13 (6) | B1, A5 |
| venda | Vendas nas filiais 2 e 3, que não têm nenhum produto cadastrado | 4 (1) | B1 |
| venda | Quantidade fracionada com unidade "UN" | 5 (2) | B2 |
| venda | Mesmo `valor_unitario` em produtos diferentes (vendas 21 a 28 copiam preços das vendas 13 a 20) | 21 (13) | B3 |
| venda | `valor_unitario` diferente do `preco_venda` do cadastro (em todas as vendas com cadastro) | 20 (8) | B4 |
| venda | Horário igual (08:00:00) em todas as vendas, provável valor padrão | 33 (14) | B5 |
| pedido_compra | `ordem_compra = 0`, sem vínculo com entrada (pedidos 19 a 29) | 11 (9) | C1 |
| pedido_compra | `data_entrega` anterior a `data_pedido` | 20 (16) | C3 |
| pedido_compra | Mesmo produto em mais de um pedido (pedidos 21 a 29 repetem os produtos P12 a P20 dos pedidos 12 a 20) | 18 linhas, 9 produtos (14) | C7 |
| pedido_compra | `fornecedor_id` diferente do fornecedor do cadastro do produto; além disso o código é numérico (1, 2 ...) e no cadastro é texto (F1, F2 ...) | 22 (11) | D2 |
| pedido_compra | Dados soltos fora da tabela: colunas M a W, linhas 22 a 30, sem cabeçalho (parecem cópia deslocada de pedidos); não aparecem no banco e são descartados pela importação | 9 linhas, 11 colunas | Só na planilha; ver a aba `pedido_compra`, colunas M:W |
| entradas_mercadoria | Entrada sem pedido correspondente (NFE19 e NFE20, ordens 19 e 20) | 2 (1) | C2 |
| entradas_mercadoria | `data_entrada` anterior a `data_pedido` | 9 (7) | C4 |
| entradas_mercadoria | `qtde_recebida` maior que `qtde_pedida` | 7 (3) | C5 |
| entradas_mercadoria | `qtde_recebida` diferente de `qtde_entregue` do pedido | 18 (8) | C5 |
| entradas_mercadoria | `custo_unitario` diferente do `preco_compra` do pedido (todas as entradas com pedido) | 18 (8) | C6 |
| produtos_filial | `preco_venda` menor que `preco_compra` (P1, P8, P15, P18) | 4 | D1 |
| produtos_filial | `preco_unitario` diferente de `preco_venda` em todos os produtos; significado do campo incerto | 20 | D4 |
| produtos_filial | Vendas de fevereiro acima do estoque (P14: 53 vendidas e estoque 9) | 1 | D5 |
| fornecedor | Fornecedores sem nenhum produto (F14, F15 e F16) | 3 | D3 |

Pontos de atenção que dependem de resposta do cliente, sem erro comprovado: só 6 dos 28 dias de fevereiro têm venda (A3).
