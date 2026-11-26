<?php
date_default_timezone_set('America/Sao_Paulo');
$mesAtual = (int)date('n');
$anoAtual = (int)date('Y');
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Atividades do Dia</title>
</head>
<body>
    <h2>Cadastrar Atividade</h2>
    <form method="post" action="cadastrar_atividade.php">
        <label>Dia:</label><br>
        <input type="text" name="dia" placeholder="Ex: 15 ou 15/11/2026" required><br><br>
        <label>Atividade:</label><br>
        <input type="text" name="atividade" required><br><br>
        <button type="submit">Cadastrar</button>
    </form>

    <hr>

    <h2>Mostrar Atividades do Mês</h2>
    <form method="get" action="mostrar_atividade.php">
        <label>Mês:</label><br>
        <select name="mes">
            <option value="1" <?= $mesAtual == 1 ? 'selected' : '' ?>>Janeiro</option>
            <option value="2" <?= $mesAtual == 2 ? 'selected' : '' ?>>Fevereiro</option>
            <option value="3" <?= $mesAtual == 3 ? 'selected' : '' ?>>Março</option>
            <option value="4" <?= $mesAtual == 4 ? 'selected' : '' ?>>Abril</option>
            <option value="5" <?= $mesAtual == 5 ? 'selected' : '' ?>>Maio</option>
            <option value="6" <?= $mesAtual == 6 ? 'selected' : '' ?>>Junho</option>
            <option value="7" <?= $mesAtual == 7 ? 'selected' : '' ?>>Julho</option>
            <option value="8" <?= $mesAtual == 8 ? 'selected' : '' ?>>Agosto</option>
            <option value="9" <?= $mesAtual == 9 ? 'selected' : '' ?>>Setembro</option>
            <option value="10" <?= $mesAtual == 10 ? 'selected' : '' ?>>Outubro</option>
            <option value="11" <?= $mesAtual == 11 ? 'selected' : '' ?>>Novembro</option>
            <option value="12" <?= $mesAtual == 12 ? 'selected' : '' ?>>Dezembro</option>
        </select><br><br>
        <label>Ano:</label><br>
        <input type="number" name="ano" value="<?= $anoAtual ?>" required><br><br>
        <button type="submit">Mostrar</button>
    </form>
</body>
</html>
