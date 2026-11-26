<?php
header('Content-Type: application/json; charset=utf-8');
date_default_timezone_set('America/Sao_Paulo');

$diaTexto = trim($_REQUEST["dia"] ?? "");
$atividade = trim($_REQUEST["atividade"] ?? "");
$mes = (int)($_REQUEST["mes"] ?? date("n"));
$ano = (int)($_REQUEST["ano"] ?? date("Y"));

if ($diaTexto == "" || $atividade == "") {
    echo json_encode(["erro" => "Preencha o dia e a atividade!"], JSON_UNESCAPED_UNICODE);
    exit;
}

if (preg_match('/^(\d{1,2})$/', $diaTexto, $m)) {
    $diaNum = (int)$m[1];
} elseif (preg_match('/^(\d{1,2})[\/\-](\d{1,2})$/', $diaTexto, $m)) {
    $diaNum = (int)$m[1];
    $mes = (int)$m[2];
} elseif (preg_match('/^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})$/', $diaTexto, $m)) {
    $diaNum = (int)$m[1];
    $mes = (int)$m[2];
    $ano = (int)$m[3];
} elseif (preg_match('/^(\d{4})[\/\-](\d{1,2})[\/\-](\d{1,2})$/', $diaTexto, $m)) {
    $ano = (int)$m[1];
    $mes = (int)$m[2];
    $diaNum = (int)$m[3];
} else {
    echo json_encode(["erro" => "Informe um dia válido!"], JSON_UNESCAPED_UNICODE);
    exit;
}

if (!checkdate($mes, $diaNum, $ano)) {
    echo json_encode(["erro" => "Data inválida!"], JSON_UNESCAPED_UNICODE);
    exit;
}

$dataSql = sprintf('%04d-%02d-%02d', $ano, $mes, $diaNum);

$dsn = 'mysql:dbname=projeto;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';
$dbh = new PDO($dsn, $user, $password);

$stmt = $dbh->prepare("INSERT INTO `atividade` (`dia`, `atividade`) VALUES (?, ?)");
$ok = $stmt->execute([$dataSql, $atividade]);

if ($ok) {
    echo json_encode([
        "id" => (int)$dbh->lastInsertId(),
        "dia" => sprintf('%02d/%02d/%04d', $diaNum, $mes, $ano),
        "atividade" => $atividade,
        "mes" => $mes,
        "ano" => $ano
    ], JSON_UNESCAPED_UNICODE);
} else {
    echo json_encode(["erro" => "Erro ao cadastrar atividade!"], JSON_UNESCAPED_UNICODE);
}
?>
