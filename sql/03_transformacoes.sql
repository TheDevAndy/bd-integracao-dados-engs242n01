-- 03_transformacoes
-- Nome: Concatenar produto_id e descrição / Transformar datas para DD/MM/YYYY 
-- Filtrar produtos requisitados mais de 10 vezes no período.
SELECT
    pc.produto_id || ' - ' || p.descricao AS produto,
    pc.qtde_pedida AS quantidade_requisitada,
    TO_CHAR(pc.data_pedido, 'DD/MM/YYYY')
        AS data_solicitacao
FROM public.pedido_compra AS pc
INNER JOIN public.produtos_filial AS p
    ON pc.produto_id = p.produto_id
    AND pc.filial_id = p.filial_id
WHERE pc.qtde_pedida > 10
ORDER BY pc.data_pedido;

-- Nome: Criar uma trigger para gerar automaticamente um novo id_fornecedor
CREATE SEQUENCE IF NOT EXISTS fornecedor_id_seq;

SELECT setval(
    'fornecedor_id_seq',
    COALESCE(
        (SELECT MAX(id_fornecedor) FROM public.fornecedor),
        0
    ) + 1,
    false
);

CREATE OR REPLACE FUNCTION gerar_fornecedor_automatico()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    novo_id INTEGER;
BEGIN
    IF NEW.id_fornecedor IS NULL THEN

        novo_id := nextval('fornecedor_id_seq');

        INSERT INTO public.fornecedor (
            id_fornecedor,
            razao_social
        )
        VALUES (
            novo_id,
            'Fornecedor automatico ' || novo_id
        );

        NEW.id_fornecedor := novo_id;

    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_gerar_fornecedor
BEFORE INSERT ON public.produtos_filial
FOR EACH ROW
EXECUTE FUNCTION gerar_fornecedor_automatico();

INSERT INTO public.produtos_filial (
    filial_id,
    produto_id,
    descricao,
    estoque,
    preco_unitario,
    preco_compra,
    preco_venda
)
VALUES (
    1,
    '999',
    'Produto de teste',
    10,
    20.00,
    15.00,
    25.00
);

SELECT *
FROM public.produtos_filial
WHERE produto_id = '999';

SELECT *
FROM public.fornecedor
ORDER BY id_fornecedor DESC
LIMIT 1;

