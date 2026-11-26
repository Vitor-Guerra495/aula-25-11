<?php
header('Content-Type: application/json; charset=utf-8');
date_default_timezone_set('America/Sao_Paulo');

$mes = (int)($_REQUEST["mes"] ?? date("n"));
$ano = (int)($_REQUEST["ano"] ?? date("Y"));

$dsn = 'mysql:dbname=projeto;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';
$dbh = new PDO($dsn, $user, $password);

$stmt = $dbh->prepare(
    "SELECT a.`id`, DATE_FORMAT(a.`dia`, '%d/%m/%Y') AS `dia`, a.`atividade`
     FROM `atividade` a
     WHERE MONTH(a.`dia`) = ? AND YEAR(a.`dia`) = ?
     ORDER BY a.`dia` DESC, a.`id` DESC"
);
$stmt->execute([$mes, $ano]);
$atividades = $stmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($atividades as &$item) {
    $item["id"] = (int)$item["id"];
}

echo json_encode([
    "mes" => $mes,
    "ano" => $ano,
    "atividades" => $atividades
], JSON_UNESCAPED_UNICODE);
?>
