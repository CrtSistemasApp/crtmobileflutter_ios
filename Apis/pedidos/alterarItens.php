<?php
header('Content-Type: application/json');
$host = $_GET['host'];
$dbname = $_GET['bdname'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$user = $_GET['usuario'];
$pass = $_GET['senha'];


date_default_timezone_set('America/Sao_Paulo');


try {
    $pdo = new PDO($dns, $user, $pass);

    $ORCID = $_POST['ORCID'];
    $PROID = $_POST['PROID'];
    $ORIVALOR = $_POST['ORIVALOR'];
    $ORIQTD = $_POST['ORIQTD'];
    $ORIDESCONTO = $_POST['ORIDESCONTO'];
    $LOCID = $_POST['LOCID'];
    $TAMID = $_POST['TAMID'];
    $CORID = $_POST['CORID'];
    $ORIOBS = $_POST['ORIOBS'];
    $EDIT = $_POST['EDIT'];

    $ORISTATUS = 'A';
    $res = $pdo->query("SELECT * FROM ORCAMENTOITENS WHERE ORCID = '$ORCID';");
    $dados = $res->fetchAll(PDO::FETCH_ASSOC);
    $linhas = count($dados);
    if ($linhas > 0) {

        $PROIDREC = $dados[0]['PROID'];
        $CORIDREC = $dados[0]['TAMID'];
        $TAMIDREC = $dados[0]['CORID'];
        

    }

    if ($PROID  == @$PROIDREC && $TAMID == @$TAMIDREC && $CORID == @$CORIDREC) {


        $res = $pdo->prepare("UPDATE ORCAMENTOITENS SET ORCID=?, PROID=?, ORIVALOR=?, ORIQTD=?, ORIDESCONTO=?, LOCID=?, ORIOBS=?, TAMID=?, CORID=?, ORISTATUS=? WHERE ORCID=? AND PROID=? ");
        $result = $res->execute([$ORCID, $PROID, $ORIVALOR, $ORIQTD, $ORIDESCONTO, $LOCID, $ORIOBS, $TAMID, $CORID, $ORCSTATUS, $ORCID, $PROID]);

        echo (json_encode(array("message" => 'item alterado com sucesso')));
    } else {
        $res = $pdo->prepare("INSERT into ORCAMENTOITENS (ORCID, PROID, ORIVALOR, ORIDESCONTO, ORIQTD, LOCID, ORIOBS, TAMID, CORID) VALUES (?,?,?,?,?,?,?,?,?)");
        $result = $res->execute([$ORCID, $PROID, $ORIVALOR, $ORIDESCONTO, $ORIQTD, $LOCID, $ORIOBS, $TAMID, $CORID]);
        echo (json_encode(array("message" => 'item adicionado com sucesso ')));
    }
} catch (Exception $e) {

    echo "Erro ao conectar com o banco de dados! " . $e;
}
