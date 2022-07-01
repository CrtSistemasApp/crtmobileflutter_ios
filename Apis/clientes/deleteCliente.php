<?php 

$cpf_cnpj = $_GET['cpf_cnpj'];	
$host = $_GET['host'];
$dbname = $_GET['bdname'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$user = $_GET['usuario'];
$pass = $_GET['senha'];


try {
    $pdo = new PDO($dns, $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
  
    $stmt = $pdo->prepare('DELETE FROM CLIENTES WHERE CLICPF = :cpf_cnpj');
    $stmt->bindParam(':cpf_cnpj', $cpf_cnpj);
    $stmt->execute();
  
    echo $stmt->rowCount();

  } catch(PDOException $e) {
    echo 'Error: ' . $e->getMessage();
  }

?>




 ?>