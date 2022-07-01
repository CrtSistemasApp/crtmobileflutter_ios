<?php 
header('Content-Type: application/json');

$host= $_GET['host'];
$dbname=$_GET['bdname'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$user = $_GET['usuario'];
$pass = $_GET['senha'];


date_default_timezone_set('America/Sao_Paulo');


try {
    $pdo = new PDO($dns, $user, $pass);

$nomeFantasia = $_POST['nomeFantasia'];
$razaosocial = $_POST['razaosocial'];
$cpf_cnpj = $_POST['cpf_cnpj'];
$rg_ie = $_POST['rg_ie'];
$tel1 = $_POST['tel1'];
$tel2 = $_POST['tel2'];
$tipoPessoa = $_POST['tipoPessoa'];
$email = $_POST['email'];
$site = $_POST['site'];
$obs = $_POST['obs'];
$logradouro = $_POST['logradouro'];
$cidade = $_POST['cidade'];
$bairro = $_POST['bairro'];
$cep = $_POST['cep'];
$uf = $_POST['uf'];
$clistatus = "U";
$idcliente = $_POST['id'];
$munid= $_GET['munid'];


$res = $pdo->prepare("UPDATE CLIENTES SET CLINOME=?, CLINOMERAZAO=?, CLICPF=?, CLIRG=?, CLIFONE01=?, CLIFONE02=?, CLITIPOCLIENTE=?, CLIEMAIL=?, CLICONTATO=?, CLICOMENTARIO=?, CLIENDERECO=?, CLICIDADE=?, CLICEP=?, CLIBAIRRO=?, CLIUF=?, CLISTATUS=?, MUNID=?  WHERE CLIID=?");


$result = $res->execute([$nomeFantasia, $razaosocial, $cpf_cnpj, $rg_ie, $tel1, $tel2, $tipoPessoa, $email, $site, $obs, $logradouro, $cidade, $cep,  $bairro, $uf, $clistatus, $munid, $idcliente]);


echo json_encode([
    'success' => $result
]);

} catch (Exception $e) {

    echo "Erro ao conectar com o banco de dados! " . $e;
}
?>