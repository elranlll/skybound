<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact Us</title>

    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f7fc; /* Soft background color */
            color: #333;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            background: linear-gradient(135deg, #6e7a90, #8390a2); /* Subtle gradient background */
        }

        .container {
            background-color: white;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
            width: 100%;
            max-width: 800px;
            text-align: center;
        }

        .header {
            font-size: 36px;
            font-weight: bold;
            color: #333;
            margin-bottom: 30px;
            text-transform: uppercase;
            letter-spacing: 2px;
            background-color: blue;
            background-clip: text;
            color: transparent;
            padding-bottom: 10px;
        }

        .form-group {
            margin-bottom: 20px;
            text-align: left;
            display: flex;
            flex-direction: column;
            align-items: flex-start;
        }

        .form-group label {
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 8px;
            color: #555;
        }

        .form-group input,
        .form-group textarea {
            width: 100%;
            padding: 14px;
            font-size: 16px;
            border-radius: 8px;
            border: 1px solid #ccc;
            background-color: #f7f8fa;
            color: #333;
            transition: all 0.3s ease;
        }

        .form-group input:focus,
        .form-group textarea:focus {
            border-color: #ff6b81;
            background-color: #fff3f3;
            outline: none;
        }

        .form-group textarea {
            resize: vertical;
            height: 150px;
        }

        .button {
            padding: 15px 30px;
            background-color: blue;
            color: white;
            font-size: 16px;
            font-weight: bold;
            border-radius: 50px;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-top: 20px;
            width: 100%;
        }

        .button:hover {
            background-color: darkblue;
            transform: translateY(-3px);
        }

        .button:active {
            background-color: blue;
            transform: translateY(1px);
        }

        .button:focus {
            outline: none;
        }

        .footer {
            margin-top: 30px;
            font-size: 14px;
            color: #777;
        }

        .footer a {
            color: blue;
            text-decoration: none;
            font-weight: bold;
        }

        .footer a:hover {
            text-decoration: underline;
        }

        /* Responsive styling */
        @media (max-width: 768px) {
            .container {
                padding: 20px;
            }
        }

    </style>
</head>
<body>

    <div class="container">
        <div class="header">
            Contact Us
        </div>

        <form action="#" method="POST">
            <div class="form-group">
                <label for="name">Your Name:</label>
                <input type="text" id="name" name="name" placeholder="Enter your name" required>
            </div>

            <div class="form-group">
                <label for="email">Your Email:</label>
                <input type="email" id="email" name="email" placeholder="Enter your email" required>
            </div>

            <div class="form-group">
                <label for="subject">Subject:</label>
                <input type="text" id="subject" name="subject" placeholder="Enter the subject" required>
            </div>

            <div class="form-group">
                <label for="message">Your Message:</label>
                <textarea id="message" name="message" placeholder="Enter your message" required></textarea>
            </div>

            <button type="submit" class="button">Send Message</button>
        </form>

        <div class="footer">
            <p>Need help? <a href="mailto:contact@company.com">Email us directly</a></p>
        </div>
    </div>

</body>
</html>