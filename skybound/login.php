<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Form</title>
       <style>
        html, body {
            height: 100%;
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            background: #f5f5f5;
        }

        .login-box {
            width: 300px;
            padding: 40px;
            background: #fff;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
            box-sizing: border-box;
        }

        .login-box h2 {
            margin: 0 0 20px;
            text-align: center;
            font-size: 24px;
            color: #333;
        }

        .user-box {
            margin-bottom: 20px;
            position: relative;
        }

        .user-box input {
            width: 100%;
            padding: 10px;
            font-size: 16px;
            color: #333;
            border: 1px solid #ccc;
            border-radius: 4px;
            outline: none;
            background: #f5f5f5;
        }

        .user-box input:focus {
            border-color: #03f484;
        }

        .user-box label {
            position: absolute;
            top: -8px;
            left: 10px;
            font-size: 12px;
            color: #777;
            background: #fff;
            padding: 0 5px;
        }

        /* Simplified Button style for Submit */
        .login-box a.submit-link {
        display: block;
        padding: 10px;
        color: black; /* Black text */
        background: lightblue; /* Blue background */
        text-align: center;
        text-decoration: none;
        font-size: 16px;
        border-radius: 4px;
       
        }

        .login-box a.submit-link:hover {
            color: whitesmoke;
        }

        .extra-links {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
            font-size: 14px;
        }

        .extra-links a {
            color: black;
            text-decoration: none;
            transition: color 0.3s;
        }

        .extra-links a:hover {
            color: black;
        }
    </style>
</head>

<body>
    <div class="login-box">
        <h2>Login Form</h2>
        <form action="">
            <div class="user-box">
                <input type="text" required>
                <label>Email</label>
            </div>
            <div class="user-box">
                <input type="password" required>
                <label>Password</label>
            </div>
            <!-- Hyperlink styled Submit -->
            <a href="#" class="submit-link">Submit</a>
        </form>
        <div class="extra-links">
            <a href="#">Forgot Password?</a>
            <a href="#">Sign Up</a>
            
        </div>
    </div>
</body>

</html>