<!DOCTYPE html>
<html lang="en" dir="ltr">
<meta charset="utf-8">
<head>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/water.css@2/out/light.min.css">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
<style>

.Info {
  position: absolute;
  left: 950px;
  border: 2px solid #000; /* Border color and thickness */
  border-radius: 20px; /* Border radius to make it look like a square */
  background-color: WHITE; 
  padding: 20px;
  width: 800px;
  height: 900px;
  top: 30px;
  font-family: "Tahoma";
}


body {
  background-image: linear-gradient(to left, #FFFFFF, #ECECEC);
}

.storymanialogo {
  position: absolute;
  top:200px;
  left:90px;
  width:800px; 
  height:400px;
}

.log {
            background-color: white;
            color: black;
            width: 520px;
            font-family: "Tahoma";
            border: 2px solid black; /* Adding black border */
            padding: 10px 20px; /* Optional: add padding to make it look nicer */
            text-align: center; /* Optional: center the text inside the button */
            text-decoration: none; /* Ensure no underline if it's an <a> tag */
            display: inline-block; /* Ensure the element behaves like a button */
            font-size: 16px; /* Optional: adjust font size */
            cursor: pointer; /* Optional: show pointer cursor on hover */
        }


#gender{
  width: 530px;
  text-align: center;
}

.reg{
  background-color: black;
  color: white;
  width: 520px;
  font-family: "Tahoma";
}
</style>
</head>
<body>


<br><br><br><br>
<div class="Info"><center>
<h1><strong>CREATE ACCOUNT</strong> </h1>

<form class= "" method="post" action="" autocomplete= "off">
      <label for="username">USERNAME</label>
      <input type="text" name="username" id= "username" size="60" required value=""><br>
      <label for="email" >EMAIL</label>
      <input type="email" id="email" name="email" size="60" required><br>
      <label for="password">PASSWORD </label>
      <input type="password" name="pass" size="60" required><br>
      <label for="confirmpass">CONFIRM PASSWORD </label>
      <input type="password" name="confirmpass" size="60" required><br> 
      <label for="lastname">WHAT IS YOUR LAST NAME?</label>
      <input type="text" name="lastname" size="60" required><br> 
     
      
      <button type="submit" name="submit" class="reg">REGISTER</button><br><br>
      <button class="log" onclick="window.location.href='login.php';">LOGIN</button>
  </form>

</center>
</div>


<?php
$message = ''; // Initialize $message variable

require 'connection.php';

if (isset($_POST["submit"])) {
    $username = $_POST['username'];
    $email = $_POST['email'];
    $gender = $_POST['gender'];
    $Pass = $_POST['pass'];
    $Confirmpass = $_POST['confirmpass'];
    $Lastname = $_POST['lastname'];
    $Favnum = $_POST['favnum'];

    // Password validation using regular expressions
    $uppercase = preg_match('@[A-Z]@', $Pass);
    $lowercase = preg_match('@[a-z]@', $Pass);
    $number    = preg_match('@[0-9]@', $Pass);
    
    if(!$uppercase || !$lowercase || !$number || strlen($Pass) < 8) {
       $message = 'Password must contain at least one uppercase letter, one lowercase letter, one digit, and be at least 8 characters long';
    } else {
        $duplicate = mysqli_query($conn, "SELECT * FROM register WHERE username = '$username'");
        if(mysqli_num_rows($duplicate) > 0) {
            $message = 'Username has already been taken';
        } else {
            if($Pass == $Confirmpass) {
                $query = "INSERT INTO register VALUES ('', '$username','$email','$gender', '$Pass', '$Confirmpass', '$Lastname', '$Favnum')";
                mysqli_query($conn, $query);
                $message = 'Registration Successful';
            } else {
               $message = 'Password does not match';
            }
        }
    }
}
?>
<?php if ($message): ?>
<div class="modal fade" id="messageModal" tabindex="-1" role="dialog" aria-labelledby="messageModalLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="messageModalLabel">Message</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <?php echo $message; ?>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>

<script>
  var myModal = new bootstrap.Modal(document.getElementById('messageModal'), {
    keyboard: false
  });
  myModal.show();
</script>
<?php endif; ?>
</body>
</html>
