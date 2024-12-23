<?php
include 'connection.php';

// Fetch domestic and international airports using views
$query_domestic = "SELECT * FROM domestic_airports_view";
$query_international = "SELECT * FROM international_airports_view";

$result_domestic = mysqli_query($conn, $query_domestic);
$result_international = mysqli_query($conn, $query_international);

// Check for errors
if (!$result_domestic || !$result_international) {
    die("Query failed: " . mysqli_error($conn));
}

// Fetch results into arrays for JavaScript
$domestic_airports = [];
$international_airports = [];

while ($row = mysqli_fetch_assoc($result_domestic)) {
    $domestic_airports[] = $row;
}
while ($row = mysqli_fetch_assoc($result_international)) {
    $international_airports[] = $row;
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@600;700&display=swap" rel="stylesheet">
  
  <title>Dashboard with Background Image</title>
  <link rel="stylesheet" href="css/main.css">
  <script>
function showModal(message) {
    // Update modal message
    document.getElementById('modalMessage').innerText = message;
    // Show modal
    document.getElementById('validationModal').style.display = 'block';
}

function closeModal() {
    // Hide modal
    document.getElementById('validationModal').style.display = 'none';
}

function validateAndRedirect() {
    const tripType = document.getElementById('roundtrip').value;
    const origin = document.getElementById('from').value;
    const destination = document.getElementById('to').value;
    const departDate = document.getElementById('depart-date').value;
    const returnDate = document.getElementById('return-date').value;

    // Validate required fields
    if (!origin || !destination) {
        showModal("Please select both origin and destination airports.");
        return false;
    }

    if (!departDate) {
        showModal("Please select a departure date.");
        return false;
    }

    if (tripType === 'roundtrip') {
        if (!returnDate) {
            showModal("Please select a return date for your round-trip.");
            return false;
        }
        if (new Date(returnDate) <= new Date(departDate)) {
            showModal("Return date must be after the departure date.");
            return false;
        }
    }

    document.forms[0].submit();
}



  // Store airport data in JavaScript
const domesticAirports = <?php echo json_encode($domestic_airports); ?>;
const internationalAirports = <?php echo json_encode($international_airports); ?>;

// Function to populate dropdowns based on flight type selection
function updateAirports() {
    const flightType = document.getElementById('flight_type').value;
    const originDropdown = document.getElementById('from');
    const destinationDropdown = document.getElementById('to');

    // Clear existing options and add a placeholder
    originDropdown.innerHTML = '<option value="" disabled selected>Select Origin</option>';
    destinationDropdown.innerHTML = '<option value="" disabled selected>Select Destination</option>';

    // Clear hidden inputs
    document.getElementById('origin-name').value = '';
    document.getElementById('origin-code').value = '';
    document.getElementById('destination-name').value = '';
    document.getElementById('destination-code').value = '';

    let airports = [];
    if (flightType === 'domestic') {
        airports = domesticAirports;
    } else if (flightType === 'international') {
        // Include Manila (MNL) as origin for international flights
        airports = internationalAirports;
    }
// Add Manila (MNL) as a valid origin for international flights
if (flightType === 'international') {
    const mnlOption = `<option value="1" data-name="Manila" data-code="MNL">
      <small>Manila</small> <span style="font-weight: bold;">- MNL</span>
    </option>`;
    originDropdown.innerHTML += mnlOption;
  }


    // Populate origin dropdown
    airports.forEach(airport => {
        const option = `<option value="${airport.airport_id}" data-name="${airport.airport_name}" data-code="${airport.airport_code}">
            <small>${airport.airport_name}</small> <span style="font-weight: bold;">- ${airport.airport_code}</span>
        </option>`;
        originDropdown.innerHTML += option;
    });

    // Update destination options based on origin
    originDropdown.addEventListener('change', function() {
        updateDestinationOptions(originDropdown.value, flightType);
        // Update hidden input for selected origin
        const selectedOption = originDropdown.options[originDropdown.selectedIndex];
        document.getElementById('origin-name').value = selectedOption.getAttribute('data-name');
        document.getElementById('origin-code').value = selectedOption.getAttribute('data-code');
    });

    // Update destination dropdown based on selected origin
    updateDestinationOptions(originDropdown.value, flightType);
}


function updateDestinationOptions(originValue, flightType) {
  const destinationDropdown = document.getElementById('to');
  
  // Reset destination options
  destinationDropdown.innerHTML = '<option value="" disabled selected>Select Destination</option>';

  // Disable the destination dropdown until origin is selected
  destinationDropdown.disabled = !originValue;

  if (!originValue) {
    return; // If no origin is selected, do not populate destination options
  }

  let airports = [];
  if (flightType === 'domestic') {
    if (originValue == '1') {
      airports = domesticAirports.slice(1, 25); // Exclude MNL as destination for domestic flights
    } else {
      airports = [{ airport_id: 1, airport_name: "Manila", airport_code: "MNL" }];
    }
  }

  if (flightType === 'international') {
        if (originValue == '1') {
            // Filter international airports to include only those with IDs 26-107
            airports = internationalAirports.filter(airport => airport.airport_id >= 26 && airport.airport_id <= 107);
        } else {
            airports = [{ airport_id: 1, airport_name: "Manila", airport_code: "MNL" }];
        }
    }

  airports.forEach(airport => {
    const option = `<option value="${airport.airport_id}" data-name="${airport.airport_name}" data-code="${airport.airport_code}">
        <small>${airport.airport_name}</small> <span style="font-weight: bold;">- ${airport.airport_code}</span>
    </option>`;
    destinationDropdown.innerHTML += option;
  });

  // Update hidden input for destination when it changes
  destinationDropdown.addEventListener('change', function() {
    const selectedOption = destinationDropdown.options[destinationDropdown.selectedIndex];
    document.getElementById('destination-name').value = selectedOption.getAttribute('data-name');
    document.getElementById('destination-code').value = selectedOption.getAttribute('data-code');
  });
}

// Function to handle trip type selection (roundtrip / one-way)
function handleTripTypeChange() {
  const tripType = document.getElementById('roundtrip').value;
  const returnDateGroup = document.getElementById('return-date-group');

  if (tripType === 'one-way') {
    returnDateGroup.style.display = 'none';
  } else {
    returnDateGroup.style.display = 'flex';
  }
}


window.onload = function() {
    const departDateInput = document.getElementById('depart-date');
    const currentDate = new Date().toISOString().split('T')[0]; // Get current date in YYYY-MM-DD format
    departDateInput.value = currentDate;  // Set the default value to today's date
    departDateInput.setAttribute('min', currentDate);  // Set the min attribute to today
    // Set default flight type and initialize airports
    document.getElementById('flight_type').value = 'domestic';
    updateAirports(); 

    handleTripTypeChange();
    document.getElementById('roundtrip').addEventListener('change', handleTripTypeChange);
};

</script>

  <style>
          .container {
            position: absolute;
            top: 120px;
            background-color: white;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            width: 40%;
            text-align: center;
        }

        .header {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            font-size: 36px;
            font-weight: 700;
            color: blue;
            background: linear-gradient(45deg, #ff6b81, #ffb7b7);
            -webkit-background-clip: text;
            background-clip: text;
            padding: 10px 0;
            text-transform: uppercase;
            letter-spacing: 2px;
            margin-bottom: 30px;
        }

        .form-group {
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .form-group label {
            font-size: 16px;
            font-weight: bold;
            color: #555;
            margin-right: 20px;
            width: 150px;
        }

        .form-group select,
        .form-group input[type="date"] {
            width: 250px;
            padding: 12px;
            font-size: 16px;
            border-radius: 6px;
            border: 1px solid #ccc;
            background-color: #f9f9f9;
            transition: 0.3s ease;
        }

        .form-group select:focus,
        .form-group input[type="date"]:focus {
            border-color: #007BFF;
            background-color: #e7f1ff;
            outline: none;
        }

        .form-group select option {
            padding: 10px;
            background-color: #ffffff;
            color: #333;
        }

        .form-group select option:hover {
            background-color: #f1f1f1;
        }

        .button {
            padding: 15px 30px;
            background-color: #007BFF;
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
        }

        .button:hover {
            background-color: #0056b3;
            transform: translateY(-3px);
        }

        .button:active {
            background-color: #004085;
            transform: translateY(1px);
        }

        .button:focus {
            outline: none;
        }

        .content-container {
            position: relative;
            margin-top: 40px;
            background-color: blue;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            color: white;
        }

        .footer {
            font-size: 14px;
            color: #555;
            margin-top: 20px;
        }

        .footer a {
            color: #007BFF;
            text-decoration: none;
        }

        .footer a:hover {
            text-decoration: underline;
        }

        .modal {
    display: none; /* Hidden by default */
    position: fixed; /* Stay in place */
    z-index: 1000; /* Sit on top */
    left: 0;
    top: 0;
    width: 100%; /* Full width */
    height: 100%; /* Full height */
    overflow: auto; /* Enable scroll if needed */
    background-color: rgba(0, 0, 0, 0.4); /* Black w/ opacity */
}

.modal-dialog {
    position: relative;
    margin: 15% auto;
    max-width: 400px;
    background-color: white;
    border-radius: 8px;
    box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2);
    overflow: hidden;
}

.modal-header {
    display: flex;
    justify-content: flex-end;
    padding: 1px;
}

.modal-body {
    padding: 20px;
}

.close {
    cursor: pointer;
    font-size: 1.5em;
    color: red;
    border: none;
    background: none;
    font-weight: bold;
}

#modalMessage {
    color: red;
    font-size: 1.2em;
    text-align: center;
}

.navbar {
  width: 100%;
  overflow: hidden;
  padding: 1px;
  background-color: blue;
}  
.navbar a {
  float: right;
  font-size: 16px;
  color: white;
  text-align: center;
  padding: 30px 20px;
  text-decoration: none;
}

.navbar a:hover {
  background-color: blue;
  color: black; /* Change text color to white when hovering */
}

.dropdown {
  float: right;
  overflow: hidden;
}

.dropdown .dropbtn {
  font-size: 16px;
  border: none;
  outline: none;
  color: white;
  padding: 30px 20px;
  background-color: inherit;
  font-family: inherit;
  margin: 0;
}

.dropdown:hover .dropbtn {
  background-color: blue;
  color: white; /* Change text color to white when hovering */
}

.dropdown-content {
  display: none;
  position: absolute;
  background-color: #f9f9f9;
  min-width: 160px;
  box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
  z-index: 1;
}

.dropdown-content a {
  float: none;
  color: black;
  padding: 12px 16px;
  text-decoration: none;
  display: block;
  text-align: left;
}

.dropdown-content a:hover {
  background-color: #ddd;
  color: white; /* Change text color to white when hovering over dropdown items */
}

.dropdown:hover .dropdown-content {
  display: block;
}
h2 {
      text-align: center;
      color: white;
      margin-top: -50px;
      margin-left: -1100px;
      font-size: 24px;
      opacity: 0;
      animation: fadeIn 1s ease-out 0.2s forwards;
    }
  </style>
<head>

  <!-- Navbar with Logo and Skybound Airlines Name -->
  <div class="navbar">
    <div class="navbar-logo">
      
      
    </div>
    <div>
      <a href="help.php">Help</a>
      <div class="dropdown">
        <button class="dropbtn">Manage
          <i class="fa fa-caret-down"></i>
        </button>
        <div class="dropdown-content">
          
          <a href="managebooking.php">Manage Booking</a>
          <a href="flightstatus.php">Flight Status</a>
        </div>
      </div>
    </div>
  </div>

  <!-- Background Images -->
  <div class="skybound"><img src="img/logo.png" alt="Image"></div>
  <div class="bgplane"><img src="img/airplane.jpg" alt="Image"></div>



      <div class ="name">
      <h2> Skybound Airlines </h2> </div>
      </div>


      
</head>
<body>

    <div class="container">
        <div class="header">Welcome to SkyBound</div>

        <form action="booking.php" method="POST" onsubmit="return validateAndRedirect()">
    <!-- Trip Type -->
    <div class="form-group">
        <label for="roundtrip">What Kind of Trip:</label>
        <select id="roundtrip" name="trip_type">
            <option value="roundtrip">Round-trip</option>
            <option value="one-way">One-way</option>
        </select>
    </div>

    <!-- Flight Type Selection -->
    <div class="form-group">
        <label for="flight_type">Flight Type:</label>
        <select id="flight_type" name="flight_type" onchange="updateAirports()">
            <option value="domestic">Domestic</option>
            <option value="international">International</option>
        </select>
    </div>

    <!-- Origin Dropdown -->
    <div class="form-group">
        <label for="from">Origin:</label>
        <select id="from" name="origin">
            <option value="" disabled selected>Select Origin</option>
        </select>
        <!-- Hidden inputs for origin name and code -->
        <input type="hidden" id="origin-name" name="origin_name">
        <input type="hidden" id="origin-code" name="origin_code">
    </div>

    <!-- Destination Dropdown -->
    <div class="form-group">
        <label for="to">Destination:</label>
        <select id="to" name="destination">
            <option value="" disabled selected>Select Destination</option>
        </select>
        <!-- Hidden inputs for destination name and code -->
        <input type="hidden" id="destination-name" name="destination_name">
        <input type="hidden" id="destination-code" name="destination_code">
    </div>

    <!-- Departure Date -->
    <div class="form-group">
        <label for="depart-date">Depart Date:</label>
        <input type="date" id="depart-date" name="depart_date">
    </div>

    <!-- Return Date -->
    <div class="form-group" id="return-date-group">
        <label for="return-date">Return Date:</label>
        <input type="date" id="return-date" name="return_date">
    </div>

    <div class="form-group">
  <label for="seat-number">Seat Number:</label>
  <select class="form-control" id="seat-number" name="seat-number">
  <option value="default" >Select Seat</option>
    <option value="A1">A1</option>
    <option value="A2">A2</option>
    <option value="A3">A3</option>
    <option value="B1">B1</option>
    <option value="B2">B2</option>
    <option value="B3">B3</option>

    </select>
    </div>


    <button type="submit" class="button" onclick="validateAndRedirect()">Book Flight</button>
    <div class="content-container">
            <p>Explore the world with ease! Book your flight now.</p>
           </div>

           <div class="footer">
            <p>Need help? <a href="contactpage.php">Contact Us</a></p>
           </div>
</form>
           

    <div class ="name">
      <h1> Skybound Airlines </h1>
      </div>

     </form>
     </div>

     <!-- Validation Modal -->
<div id="validationModal" class="modal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header" style="border-bottom: none; justify-content: flex-end;">
                <button type="button" class="close" aria-label="Close" onclick="closeModal()" style="border: none; background: none; color: black; font-size: 1.5em; font-weight: bold;">
                    &times;
                </button>
            </div>
            <div class="modal-body" style="text-align: center;">
                <p id="modalMessage" style="color: red; font-size: 1.2em; font-weight: bold;"></p>
            </div>
        </div>
    </div>
</div>


</body>
</html>
