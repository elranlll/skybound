<?php
$host = 'localhost';          
$username = 'root';  
$password = '';  
$database = 'skybound';       

// Create a connection
$conn = new mysqli($host, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die('Connection failed: ' . $conn->connect_error);
} else {
    echo "<script>console.log('Database connected successfully');</script>";
}
 
?>


