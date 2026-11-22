# Parte 1: Documentação do processo de importação

## Ferramenta utilizada
O DDL foi executado e corrigido no software DBeaver. Após a correção as tabelas foram importadas uma por uma no formato cvs, sempre observando se o mapeamento estava sendo feito de forma correta em cada coluna. Dessa forma não foi necessário o script de importação disponibilizado pelo professor.

## Estrutura da planilha

| Aba | Coluna | Tipo | Observação |
| --- | --- | --- | --- |
| venda | venda_id | Inteiro | Identificador (1 a 20), sem repetição |
| venda | data_emissao | Data | De 03/01/2025 a 02/03/2025; formato aaaa-mm-dd |
| venda | horariomov | Hora | Todos os registros têm 08:00:00 |
| venda | produto_id | Inteiro | 1 a 20 |
| venda | qtde_vendida | Inteiro | De 2 a 90 |
| venda | valor_unitario | Decimal | De 14,41 a 197,61 |
| venda | filial_id | Inteiro | Sempre 1 |
| venda | item | Inteiro | Sempre 1 |
| venda | unidade_medida | Texto | Sempre UN |

| Aba | Coluna | Tipo | Observação |
| --- | --- | --- | --- |
| pedido_compra | pedido_id |	Inteiro |	1 a 20, sem repetição |
| pedido_compra | data_pedido |	Data | De 02/01/2025 a 01/03/2025 |
| pedido_compra | item |	Inteiro |	Sempre 1 |
| pedido_compra | produto_id |	Inteiro	| 1 a 20 |
| pedido_compra | ordem_compra |	Inteiro | 1 a 20, sem repetição |
| pedido_compra | qtde_pedida |	Inteiro |	De 12 a 99 |
| pedido_compra | filial_id |	Inteiro |	Sempre 1 |
| pedido_compra | data_entrega |	Data |	De 01/01/2025 a 28/02/2025 |
| pedido_compra | qtde_entregue |	Inteiro |	De 0 a 91 |
| pedido_compra | qtde_pendente | Inteiro |	qtde_pedida - qtde_entregue |
| pedido_compra | preco_compra |	Decimal |	De 6,92 a 85,04 |
| pedido_compra | id_fornecedor |	Inteiro |	1 a 20 |

| Aba | Coluna | Tipo | Observação |
| --- | --- | --- | --- |
| entradas_mercadoria | data_entrada |	Data | De 01/01/2025 a 01/03/2025|
| entradas_mercadoria | nro_nfe |	Texto	| NFE1 a NFE20, sem repetição |
| entradas_mercadoria | item |	Inteiro	| Sempre 1 |
| entradas_mercadoria | produto_id |	Inteiro	| 1 a 20 |
| entradas_mercadoria | qtde_recebida |	Inteiro	| De 4 a 95 |
| entradas_mercadoria | custo_unitario |	Decimal |	De 10,32 a 98,99 |
| entradas_mercadoria | ordem_compra |	Inteiro |	1 a 20 |
| entradas_mercadoria | filial_id	| Inteiro |	Sempre 1 |

| Aba | Coluna | Tipo | Observação |
| --- | --- | --- | --- |
| produtos_filial | filial_id |	Inteiro	| Sempre 1 |
| produtos_filial | produto_id |	Inteiro |	1 a 20 |
| produtos_filial | descricao	| Texto	| Produto 1 | a Produto 20 |
| produtos_filial | estoque |	Inteiro |	De 2 a 198 |
| produtos_filial | preco_unitario |	Decimal	| De 24,64 a 199,56 |
| produtos_filial | preco_compra |	Decimal |	De 7,75 a 149,50 |
| produtos_filial | preco_venda	| Decimal |	De 29,24 a 278,88 |
| produtos_filial | id_fornecedor	| Inteiro | 1 a 20 |

| Aba | Coluna | Tipo | Observação |
| --- | --- | --- | --- |
| fornecedor | id_fornecedor |	Inteiro	| 1 a 20, sem repetição |
| fornecedor | razao_social	| Texto |	Fornecedor 1 LTDA a Fornecedor 20 LTDA |

## Erros encontrados no DDL e como foram corrigidos

| Tabela | Erro | Correção |
| --- | --- | --- |
| entradas_mercadorias | A coluna “ordem_compra” não foi encontrada na tabela | Foi criada uma coluna “ordem_compra” na tabela |
| produtos_filial | Foi encontrado um erro de sintaxe | Foi acrescentado uma vírgula na linha anterior |
| produtos_filial | Não foi encontrada a coluna “idproduto” na tabela, está com um nome diferente | O nome foi corrigido para “produto_id” |
| fornecedor | Coluna “idproduto” determinda como PK, porém não existe na tabela | Foi retirada a coluna “produto_id” da PK |
| pedido_compra/produtos_filial | Coluna fornecedor com nomes diferentes em outras tabelas | Padronizado para id_fornecedor |
| fornecedor | Tipos diferentes para o mesmo dado id_fornecedor | Padronizado o tipo para int4 |
| produtos_filial | Coluna produto_id com tamanhos diferentes | Padronizada para varchar(25) |
| produtos_filial | Coluna filial_id está declarado NULL, mas faz  parte da PK | Coluna “filial_id” declarada como NOT NULL |
| venda | O DEFAULT ‘’ permite gravar uma venda sem produto | Remover o DEFAULT da coluna |

## Erros encontrados no script de importação e como foram corrigidos

| Erro | Efeito | Correção |
| --- | --- | --- |
|  |  |  |

## Tratamentos aplicados aos dados

- Fornecedor: id_fornecedor em pedido_compra ganhou o prefixo F e agora casa com a tabela de fornecedores (20 de 20 pedidos);
- Ordens de compra: os pedidos 19 e 20 passaram de ordem_compra = 0 para 19 e 20, e as 20 entradas agora casam com os pedidos;
- Vendas sem produto cadastrado: 13 vendas usam os produtos P21 a P28, que não existem em produtos_filial (que só vai até P20), as 13 vendas dos produtos P21 a P28 foram excluídas, e venda foi de 33 para 20 linhas;
- Quantidades fracionadas: 4 valores de qtde_vendida foram arredondados para inteiro (vendas 4, 8, 12 e 16);
- Filiais 2 e 3: venda tinha 4 linhas nas filiais 2 e 3, mas todas as outras abas só tinha a filial 1, as vendas com filial inexistente foram trocadas para filial. Agora as 20 vendas estão na filial 1;
- Datas: todas as datas foram pradronizadas para o formato yyyy-mm-dd em venda;
- Nomes de coluna: padronizados para produto_id e id_fornecedor em todas as abas.

## Conferência final

| Tabela | Linhas na planilha | Linhas no banco |
| --- | --- | --- |
| fornecedor | 20 | 20 |
| produtos_filial | 20 | 20 |
| pedido_compra | 20 | 20 |
| entradas_mercadoria | 20 | 20 |
| venda | 20 | 20 |
