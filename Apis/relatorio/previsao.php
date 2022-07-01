<?php

$host = $_POST['host'];
$dbname = $_POST['bdname'];
$user = $_POST['usuario'];
$pass = $_POST['senha'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$dataInicial = $_GET['dataInicial'];
$dataFinal = $_GET['dataFinal'];
$venid = $_GET['venid'];
$filtro = $_GET['filtro'];


date_default_timezone_set('America/Sao_Paulo');


try {
    $pdo = new PDO($dns, $user, $pass);

    $dados = array();

    $query = $pdo->query("select
                    distinct(p.cliid),
                    c.$filtro as clinome, p.venid, v.vennome,
                    max(p.orcdata)as compra_mais_recente,
                    min(p.orcdata)as compra_mais_antiga,
                    count(orcid) as total_de_compras,
                    CAST(AVG(orcvalortotal) AS DECIMAL(10,2)) as valor_medio_compras,
                    ((max(p.orcdata) - min(p.orcdata))/ count(orcid)) as media_de_dias,
                    ADDDATE(Date_format(FROM_UNIXTIME(((UNIX_TIMESTAMP(max(p.orcdata)) - UNIX_TIMESTAMP(min(p.orcdata))) / count(p.orcid)) + UNIX_TIMESTAMP(max(p.orcdata))), '%Y-%m-%d'), INTERVAL 2 DAY) as previsao
                    from ORCAMENTOS p,CLIENTES c,VENDEDORES v
                    where
                    p.venid = $venid and
                    (orcdata between '$dataInicial' AND '$dataFinal')
                    and
                    (p.cliid = c.cliid )
                    and
                    (v.venid = p.venid)
                    and
                    (orcstatus = 1)
                    group by p.cliid,c.$filtro HAVING count(*) > 1  order by p.orcdata");
    $res = $query->fetchAll(PDO::FETCH_ASSOC);


    for ($i = 0; $i < count($res); $i++) {
        foreach ($res[$i] as $key => $value) {
        }

        $dados = $res;
    }

    echo ($res) ?
        json_encode(array("code" => 1, "result" => $dados)) :
        json_encode(array("code" => 0, "message" => "Dados incorretos!"));
} catch (Exception $e) {

    echo "Erro ao conectar com o banco de dados! " . $e;
}
