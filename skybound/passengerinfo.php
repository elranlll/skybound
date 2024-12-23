<?php
include 'connection.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Access form fields here
    $firstName = trim($_POST['firstName'] ?? '');
    $lastName = trim($_POST['lastName'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $confirmEmail = trim($_POST['confirmEmail'] ?? '');
    $phoneNumber = trim($_POST['phoneNumber'] ?? '');
    $passportNumber = trim($_POST['passportNumber'] ?? '');
    $nationality = trim($_POST['nationality'] ?? '');
    $expiryDate = trim($_POST['expiryDate'] ?? '');

    // Input validation: Check for empty fields
    if (empty($firstName) || empty($lastName) || empty($email) || empty($confirmEmail) ||
        empty($phoneNumber) || empty($passportNumber) || empty($nationality) || empty($expiryDate)) {
        echo "Error: All fields are required.";
        exit;
    }

    // Validate email format and confirmation
    if (!filter_var($email, FILTER_VALIDATE_EMAIL) || $email !== $confirmEmail) {
        echo "Error: Invalid email format or emails do not match.";
        exit;
    }

    // Prepare procedure call
    $stmt = $conn->prepare("CALL InsertPassenger(NULL, ?, ?, ?, ?, ?, ?, ?, NOW())");
    $stmt->bind_param(
        "sssssss",
        $firstName,
        $lastName,
        $email,
        $phoneNumber,
        $passportNumber,
        $nationality,
        $expiryDate
    );

    // Execute the procedure
    if ($stmt->execute()) {
        echo "<script>console.log('Passenger information saved successfully.');</script>";
        header("Location: bookaflight.php"); // Redirect after successful insert
        exit; // Stop further script execution
    } else {
        echo "<script>console.error('Error: " . $stmt->error . "');</script>";
    }

    // Close the statement and connection
    $stmt->close();
    $conn->close();
}
?>




<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UI Panel</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }

        .navbar {
            background-color: blue;
            color: white;
            display: flex;
            align-items: center;
            padding: 40px 80px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }

        .navbar .name {
            position: absolute;
            font-size: 24px;
            font-style: italic;
            margin: 0;
            left: 200px;
        }

        .navbar .name a {
            color: white;
            text-decoration: none;
        }

        .navbar .name a:hover {
            text-decoration: underline;
        }

        .panel {
            position: absolute;
            top: 50px;
            left: 480px;   
            background: #fff;
            padding: 20px;
            height: 600px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            width: 50%;
            max-width: 800px;
            margin: 100px auto;
            text-align: left;
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            font-weight: bold;
            margin-bottom: 5px;
        }

        .form-group input, .form-group select {
            width: 40%;
            padding: 8px;
            font-size: 16px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }

        .form-group1 {
            position: relative;
            top: -600px;
            margin-left: 420px;
            margin-top: 20px;
        }

        .form-group1 label {
            top: 200px;
            display: block;
            font-weight: bold;
            margin-bottom: 5px;
        }

        .form-group1 input, .form-group1 select {
            width: 60%;
            padding: 8px;
            font-size: 16px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }

        .form-group2 {
            position: relative;
            top: -158px;
            margin-left: 420px;
            margin-top: 20px;
        }

        .form-group2 label {
            top: 200px;
            display: block;
            font-weight: bold;
            margin-bottom: 5px;
        }

        .form-group2 input, .form-group2 select {
            width: 60%;
            padding: 8px;
            font-size: 16px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }

        button {
            padding: 10px 20px;
            font-size: 16px;
            color: white;
            background-color: blue;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }

        button:hover {
            background-color: darkblue;
        }

        .skybound {
            position: absolute;
            left: 60px;
            top: -7px;
            height: 60%;
            width: 20%;
        }

        .details {
            position: absolute;
            top: 20px;
            left: 440px;
        }

        .button {
            position: absolute;
            left: 700px;
            top: 560px;
        }

        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.6);
            justify-content: center;
            align-items: center;
        }

        .modal-content {
            background-color: white;
            padding: 30px;
            border-radius: 30px;
            text-align: center;
            width: 500px;
            position: relative;
            box-shadow: 0 6px 15px rgba(0, 0, 0, 0.3);
            border: 5px solid #007bff;
        }

        .close {
            position: absolute;
            top: 15px;
            right: 15px;
            font-size: 24px;
            cursor: pointer;
            color: #007bff;
        }

        h2 {
            font-family: Arial, sans-serif;
            color: #007bff;
            margin-bottom: 20px;
        }

        .payment-option {
            display: flex;
            align-items: center;
            margin: 15px 0;
            padding: 15px;
            border: 2px solid #ccc;
            border-radius: 8px;
            cursor: pointer;
            transition: background-color 0.3s, border-color 0.3s, transform 0.2s;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }

        .payment-option img {
            width: 50px;
            height: 50px;
            margin-right: 15px;
        }

        .payment-option.selected {
            border-color: #007bff;
            background-color: #e9f7ff;
            transform: scale(1.05);
        }

        .pay-button {
            margin-top: 30px;
            padding: 15px 30px;
            background: linear-gradient(to right, #007bff, #00c6ff);
            color: white;
            font-size: 18px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: background-color 0.3s, transform 0.2s;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
        }

        .pay-button:hover {
            background-color: #0056b3;
            transform: scale(1.05);
        }

        .Logo{
            position: absolute;

        }


    </style>
</head>
<body>
<div class="skybound"><img src="img/logo.png" alt="Logo"></div>
    <div class="navbar">
        <h1 class="name">
            <a href="bookaflight.php">Skybound Airlines</a>
        </h1>
    </div>

    <div class="panel">
        <h2>Passenger Information</h2>
        <form id="mainForm" action="passengerinfo.php" method="POST">
            <div class="form-group">
                <label for="firstName">First Name</label>
                <input type="text" id="firstName" name="firstName" placeholder="Enter your first name" required>
            </div>
            <div class="form-group">
                <label for="lastName">Last Name</label>
                <input type="text" id="lastName" name="lastName" placeholder="Enter your last name" required>
            </div>
            <div class="form-group">
                <label for="gender">Gender</label>
                <select id="gender" name="gender" required>
                    <option value="" disabled selected>Select your gender</option>
                    <option value="Male">Male</option>
                    <option value="Female">Female</option>
                </select>
            </div>
            <div class="form-group">
                <label for="dob">Date of Birth</label>
                <input type="date" id="dob" name="dob" required>
            </div>

            <h2>Contact Info</h2>
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" placeholder="Enter your email" required>
            </div>
            <div class="form-group">
                <label for="confirmEmail">Confirm Email</label>
                <input type="email" id="confirmEmail" name="confirmEmail" placeholder="Confirm your email" required>
            </div>
            <div id="error" class="error" style="display: none;">Emails do not match or invalid email format.</div>

            <div class="form-group2">
                <label for="phoneNumber">Phone Number</label>
                <input type="text" id="phoneNumber" name="phoneNumber" placeholder="Enter your phone number" required>
            </div>

            <div class="details">
                <h2>Passport Details</h2>
            </div>
            <div class="form-group1">
                <label for="nationality">Nationality</label>
                <input type="text" id="nationality" name="nationality" placeholder="Enter your nationality" required>
            </div>
            <div class="form-group1">
                <label for="passportNumber">Passport Number</label>
                <input type="text" id="passportNumber" name="passportNumber" placeholder="Enter your passport number" required>
            </div>
            <div class="form-group1">
                <label for="expiryDate">Expiry Date</label>
                <input type="date" id="expiryDate" name="expiryDate" required>
            </div>
            <div class="button">
                <button type="submit">Submit</button>
            </div>
        </form>
    </div>

    <div id="paymentModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal()">&times;</span>
            <h2>Select Payment Method</h2>
            <div id="paymentOptions">
                <div class="payment-option" onclick="selectOption(this)" data-method="G-Cash">
                    <img src="img/gcash.png" alt="G-Cash Logo">
                    <span>G-Cash</span>
                </div>
                <div class="payment-option" onclick="selectOption(this)" data-method="PayPal">
                    <img src="img/paypal.png" alt="PayPal Logo">
                    <span>PayPal</span>
                </div>
                <div class="payment-option" onclick="selectOption(this)" data-method="Debit Card">
                    <img src="img/debit.png" alt="Debit Card Logo">
                    <span>Debit Card</span>
                </div>
            </div>
            <button class="pay-button" onclick="pay()">Pay</button>
        </div>
    </div>

    <script>
    const form = document.getElementById('mainForm');
    const email = document.getElementById('email');
    const confirmEmail = document.getElementById('confirmEmail');
    const error = document.getElementById('error');

    form.addEventListener('submit', function(event) {
        event.preventDefault(); // Prevent form submission

        // Check for empty fields
        const requiredFields = form.querySelectorAll('input[required], select[required]');
        let valid = true;

        requiredFields.forEach(field => {
            if (!field.value.trim()) {
                alert(`Please fill out the ${field.name} field.`);
                valid = false;
                return;
            }
        });

        // Validate emails
        if (valid && (email.value !== confirmEmail.value || !email.value.includes('@'))) {
            error.style.display = 'block';
            valid = false;
        } else {
            error.style.display = 'none';
        }

        // Open modal only if validation passes
        if (valid) {
            openModal();
        }
    });

    let selectedOption = null;

    function openModal() {
        document.getElementById('paymentModal').style.display = 'flex';
    }

    function closeModal() {
        document.getElementById('paymentModal').style.display = 'none';
    }

    function selectOption(element) {
        if (selectedOption) {
            selectedOption.classList.remove('selected');
        }
        selectedOption = element;
        selectedOption.classList.add('selected');
    }

    function pay() {
        if (selectedOption) {
            const method = selectedOption.getAttribute('data-method');
            alert(`Payment Successful with ${method}.`);
            closeModal();
            form.submit(); // Submit form only after payment success
        } else {
            alert('Please select a payment method.');
        }
    }
</script>

</body>
</html>
