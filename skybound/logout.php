<?php
session_start();

// Check if the username is set in the session
if (isset($_SESSION['username'])) {
    // Store the username in a local variable
    $username = $_SESSION['username'];
} else {
    // If no username is set, provide a default value or handle the case appropriately
    $username = 'Guest';
}

// Unset all session variables
session_unset();

// Destroy the session
session_destroy();

// Redirect to story.php with the username as a query parameter
header("Location: story.php?username=" . urlencode($username));
exit();
?>