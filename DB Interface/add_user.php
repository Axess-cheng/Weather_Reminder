<?php

include_once "functions/generic_functions.php";
include_once "functions/sql_functions.php";
include_once "include/config.php";
include_once "include/mysql_connector.php";

if (!isset($_POST["email"]) || !isset($_POST["password"]) || !isset($_POST["token"])) {
    echo json_encode(
        array(
            "error" => "Invalid parameters"
        )
    );
    return;
}

$token = $_POST["token"];

if (!validate_token($mysql, "tokens", 0, $token)) {
    echo json_encode(
        array(
            "error" => "Invalid token"
        )
    );
    return;
}

$email = $_POST["email"];
$password = $_POST["password"];
$user = get_user_result($mysql, "users", "email", $email, "s");

if ($user != null) {
    echo json_encode(
        array(
            "error" => "User already exists"
        )
    );
    return;
}

$salt = generate_string(8);
$password_hash = hash_string($password, $salt);

if (add_user($mysql, "users", $email, $password_hash, $salt)) {
    echo json_encode(
        array(
            "success" => "User created"
        )
    );
} else {
    echo json_encode(
        array(
            "error" => "User creation failed"
        )
    );
}