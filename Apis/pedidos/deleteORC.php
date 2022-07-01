<?php 


$host = $_GET['host'];
$dbname = $_GET['bdname'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$user = $_GET['usuario'];
$pass = $_GET['senha'];
$orcid = $_GET['orcid'];

try {
    $pdo = new PDO($dns, $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
  
    $stmt = $pdo->prepare('DELETE FROM ORCAMENTOS WHERE ORCID = :orcid');
    $stmt->bindParam(':orcid', $orcid);
    $stmt->execute();
  
    echo $stmt->rowCount();

  } catch(PDOException $e) {
    echo 'Error: ' . $e->getMessage();
  }

?>




 ?>