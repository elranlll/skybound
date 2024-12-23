<?php
include 'connection.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Retrieve POST data
    $flightType = $_POST['flight_type'];
    $tripType = $_POST['trip_type'];
    $origin_name = $_POST['origin_name'];
    $origin_code = $_POST['origin_code'];
    $destination_name = $_POST['destination_name'];
    $destination_code = $_POST['destination_code'];
    $departDate = $_POST['depart_date'];
    $returnDate = isset($_POST['return_date']) ? $_POST['return_date'] : null;

    
}

// Helper function to calculate price
function calculatePrice($base_price, $haul_id, $is_weekend, $type = 'economy') {
    $multipliers = [
        'weekdays' => [
            1 => [9.4999, 14.4999],
            2 => [7.4999, 12.4999],
            3 => [6.4999, 11.4999],
            4 => [4.4999, 9.4999],
        ],
        'weekends' => [
            1 => [15.4999, 17.4999],
            2 => [13.4999, 15.4999],
            3 => [12.4999, 14.4999],
            4 => [10.4999, 12.4999],
        ],
    ];

    $range = $multipliers[$is_weekend ? 'weekends' : 'weekdays'][$haul_id];
    $factor = rand($range[0] * 10000, $range[1] * 10000) / 10000; // Random float in range
    $price = $base_price * $factor;

    if ($type === 'business') {
        $price *= 2.5;
    }

    return round($price, 2);
}

// Generate flights
$flights = [];
$query = "SELECT * FROM flight_details_view WHERE origin_airport_code = ? AND destination_airport_code = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param('ss', $origin_code, $destination_code);
$stmt->execute();
$result = $stmt->get_result();
$aircraft_query = "SELECT * FROM aircraft_view";
$aircraft_result = $conn->query($aircraft_query);
$aircrafts = $aircraft_result->fetch_all(MYSQLI_ASSOC);

while ($row = $result->fetch_assoc()) {
    // Set how many variations you want
    $num_variations =rand(2, 8);

    for ($i = 0; $i < $num_variations; $i++) {
        // Randomized departure time
        $departure_time = new DateTime($departDate . ' ' . rand(0, 23) . ':' . str_pad(rand(0, 59), 2, '0', STR_PAD_LEFT));
        $duration = new DateInterval('PT' . str_replace(':', 'H', $row['duration']) . 'M');
        $arrival_time = (clone $departure_time)->add($duration);

        // Generate flight details with random elements
        $flights[] = [
            'origin_code' => $row['origin_airport_code'],
            'destination_code' => $row['destination_airport_code'],
            'departure_time' => $departure_time->format('g:i A'),
            'arrival_time' => $arrival_time->format('g:i A') . ($arrival_time->format('Y-m-d') > $departure_time->format('Y-m-d') ? ' (+1 day)' : ''),
            'duration' => $row['duration'],
            'aircraft' => $aircrafts[array_rand($aircrafts)]['aircraft_number'], // Random aircraft
            'layover' => $row['layover_status'] ? ['code' => $row['layover_airport_code'], 'name' => $row['layover_airport_name']] : null,
            'economy_price' => calculatePrice($row['base_price'], $row['haul_id'], in_array(date('N', strtotime($departDate)), [6, 7]), 'economy'),
            'business_price' => calculatePrice($row['base_price'], $row['haul_id'], in_array(date('N', strtotime($departDate)), [6, 7]), 'business'),
        ];
    }
}

?>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet">


    <style>
       body {
            background-color: blue;
            margin: 0;
            overflow-x: hidden;
        }
        .nav {
            position: fixed; 
            top: 0; 
            left: 0; 
            width: 100%; 
            z-index: 1000;
            padding: 10px 0; 
        }
        .topbg {
            position: absolute;
            background-color: darkblue;
            color: white;
            height: 100px;
            margin-right: 50px;
            margin-left: 50px;
            width: calc(100% - 100px);
            border-radius: 5px;
        }

        .disclaimer_mg {
            position: absolute; 
            top: 130px; 
            left: 50px; 
            margin-top: 5px;
            height: 90px;
            width: calc(100% - 100px);
            background-color: #ffffff;
            z-index: 10; 
            border-radius: 10px;
        }
        .para {
            position: absolute;
            top: 151px; 
            left: 120px;
            font-size: 14px;
            color: navy;
            z-index: 20; 
            font-family: Arial, Helvetica, sans-serif;
        }

        .time {
            margin-left: 50PX;
            margin-right: 50PX;
            margin-top: 250px;
            padding: 20px;
            width: calc(100% - 100px);
            background-color: #dedede;
            border-radius: 10px;
            z-index: 5;
            box-sizing: border-box;
        }

        .flight-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    background-color: white;
    border-radius: 10px;
    padding: 15px;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
    box-sizing: border-box;
   
}

.divider {
            height: 100%;
            width: 1px;
            background-color: #ccc;
            margin: 0 20px;
        }

        .flight-route {
            font-size: 18px;
            font-weight: bold;
        }

        .flight-time {
            font-size: 14px;
            color: gray;
        }
        .details-column {
            display: flex;
            flex-direction: column;
            flex: 1;
            font-family: Arial, Helvetica, sans-serif;
        }
        .info-column {
            display: flex;
            flex-direction: column;
            flex: 2;
            font-size: 12px;
            color: gray;
            text-align: left;
            margin-right: -400px;
        }
        
        .stop-column{
            display: flex;
            flex: 1;
            flex-direction: column;
            font-size: 15px;
            color: gray;
            text-align: left;
            margin-left: 0px;
        }

       

        .price {
            flex: 1;
            text-align: center;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 10px;
            border-radius: 10px;
            font-family: Arial, Helvetica, sans-serif;
            max-width: 250px;
            min-height: 35px;
        }

        .economy {
            background-color: powderblue;
            margin-right: 10px;
        }

        .business {
            background-color: #f7e17f; /* mellow yellow */
        }

        .price {
            font-size: 16px;
            font-weight: bold;
            margin-top: 5px;
        }

/* Hover effect for buttons */
.price:hover {
    background-color:transparent red;
    transform: translateY(-3px);
}

/* Active state when the button is clicked */
.price:active {
    background-color: #004085;
    transform: translateY(1px);
}

/* Focus state for accessibility */
.price:focus {
    outline: none;
}


    .origin {
    position: absolute;
    color: white;
    top: 10px;
    left: 80px;
    height: 50px;
    width: 1350px;
    font-family: Arial, Helvetica, sans-serif;
}
.origincode {
    position: absolute;
    color: white;
    top: 37px;
    left: 80px;
    height: 50px;
    width: 1350px;
    font-family: Arial, Helvetica, sans-serif;
    font-weight: bold;
}
.destination {
    position: absolute;
    color: white;
    top: 10px;
    left: 480px;
    height: 50px;
    width: 1350px;
    font-family: Arial, Helvetica, sans-serif;
}
.destinationcode {
    position: absolute;
    color: white;
    top: 37px;
    left: 480px;
    height: 50px;
    width: 1350px;
    font-family: Arial, Helvetica, sans-serif;
    font-weight: bold;
}
.depart {
    position: absolute;
    color: white;
    top: 10px;
    left: 45%;
    height: 50px;
    width: 1350px;
    font-family: Arial, Helvetica, sans-serif;
}
.departure {
    position: absolute;
    color: white;
    top: 37px;
    left: 45%;
    height: 50px;
    width: 1350px;
    font-family: Arial, Helvetica, sans-serif;
    font-weight: bold;
}
.return {
    position: absolute;
    color: white;
    top: 10px;
    left: 65%;
    height: 50px;
    width: 1350px;
    font-family: Arial, Helvetica, sans-serif;
}
.returned {
    position: absolute;
    color: white;
    top: 37px;
    left:  65%;
    height: 50px;
    width: 1350px;
    font-family: Arial, Helvetica, sans-serif;
    font-weight: bold;
}
.passenger {
    position: absolute;
    color: white;
    top: 10px;
    left: 90%;
    height: 50px;
    width: 1350px;
    font-family: Arial, Helvetica, sans-serif;
}
.passenger_no{
    position: absolute;
    color: white;
    top: 37px;
    left: 93%;
    height: 50px;
    width: 1350px;
    font-family: Arial, Helvetica, sans-serif;
    font-weight: bold;
}

.filter-container {
  display: flex;
  justify-content: flex-end;
  margin-bottom: 10px;
  font-family: Arial, sans-serif;
}

.filter-container label {
  margin-top: 6px;
  margin-right: 5px;
  font-size: 14px;
}

#flight-sort {
  padding: 5px;
  font-size: 14px;
}

.modal {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 50%;
    background-color: white;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
    border-radius: 10px;
    z-index: 1000;
    padding: 20px;
}

.modal-content {
    position: relative;
}

.close {
    position: absolute;
    top: 4px;
    right: 8px;
    color: red;
    font-size: 25px;
    cursor: pointer;
}

table {
    width: 100%;
    margin: 10px 0;
    border-collapse: collapse;
}

table td {
    padding: 10px;
    border: 1px solid #ddd;
}

#confirm-button {
    display: block;
    margin: 20px auto 0;
    padding: 10px 20px;
    font-size: 16px;
    background-color: #007BFF;
    color: white;
    border: none;
    border-radius: 5px;
    cursor: pointer;
}

#confirm-button:hover {
    background-color: #0056b3;
}
 </style>
</head>
<body>
   
    </div>
    <div class="para">
        <strong>Fare disclaimer:</strong> Fares are ALL-IN and not guaranteed until final purchase. 
        Prices INCLUDE government taxes and surcharges EXCEPT Philippine Travel Tax, other charges 
        and fees that are collected at the airport. Taxes and fees are approximate <br>(exact amount will 
        be displayed on the next page). There may be additional fees for your checked baggage in excess 
        of your free baggage allowance. Price is for one traveler and includes taxes.
     </div>
      
     <div class=note>
     <div class="disclaimer_mg "></div>
     <i class='fas fa-exclamation-circle' style='font-size:25px;color:blue; position: absolute; top: 150px; left: 70px; z-index: 20;'></i>
</div>
    <div class="nav">
    <div class="topbg"></div>
    <div class="topbg"></div>
        <div class="origin">
            <h3><?php echo htmlspecialchars($origin_name); ?></h3>
        </div>
        <div class="origincode">
            <h1><?php echo htmlspecialchars($origin_code); ?></h1>
        </div>
        <div class="destination">
            <h3><?php echo htmlspecialchars($destination_name); ?></h3>
        </div>
        <div class="destinationcode">
            <h1><?php echo htmlspecialchars($destination_code); ?></h1>
        </div>
        <div class="depart">
            <h3>Depart</h3>
        </div>
        <div class="departure">
            <h1><?php echo htmlspecialchars($departDate); ?></h1>
        </div>
        <?php if ($tripType === 'roundtrip'): ?>
            <div class="return">
                <h3>Return</h3>
            </div>
            <div class="returned">
                <h1><?php echo htmlspecialchars($returnDate); ?></h1>
            </div>
        <?php endif; ?>
    <div class="passenger">
        <h3>Passenger</h3>
    </div>
    <div class="passenger_no">
        <h1>1</h1>
    </div>
    <i class='fas fa-arrows-alt-h' style='font-size:48px;color:white; position: absolute; top: 40px; left: 280px;'></i>
    <i class='fas fa-user-alt' style='font-size:32px;color:white; position: absolute; top: 58px; left: 90%;'></i>
       </div>

       <div class="time">
       <div class="filter-container">
       <label for="flight-sort">Sort by:</label>
  <select id="flight-sort">
    <option value="" disabled selected>Select sorting option</option>
    <option value="lowest">Lowest Price</option>
    <option value="earliest">Earliest Departure Time</option>
  </select>
</div>
    <?php foreach ($flights as $flight): ?>
        <div class="flight-row" >
            <!-- Flight Details Column -->
            <div class="details-column">
                <div class="flight-route"><?php echo htmlspecialchars($flight['origin_code']) . " &#8594; " . htmlspecialchars($flight['destination_code']); ?></div>
                <div class="flight-time"><?php echo htmlspecialchars($flight['departure_time']) . " - " . htmlspecialchars($flight['arrival_time']); ?></div>
            </div>

            <!-- Divider -->
            <div class="divider"></div>

            <!-- Additional Info Column -->
            <div class="info-column">
                <div class="duration">Duration: <?php echo htmlspecialchars($flight['duration']); ?></div>
                <div class="airplane">Aircraft: <?php echo htmlspecialchars($flight['aircraft']); ?></div>
            </div>

            <!-- Stop/Layover Column -->
            <div class="stop-column">
                <?php if ($flight['layover']): ?>
                    <div class="layover"><?php echo htmlspecialchars($flight['layover']['code']); ?></div>
                    <div class="stop">Layover</div>
                <?php endif; ?>
            </div>

            <!-- Economy Price -->
            <button type="button" class="price economy" id="economy">
                <div>Economy</div>
                <div class="price">PHP <?php echo number_format($flight['economy_price'], 2); ?></div>
            </button>

            <!-- Business Price -->
            <button type="button" class="price business" id="business">
                <div>Business</div>
                <div class="price">PHP <?php echo number_format($flight['business_price'], 2); ?></div>
            </button>
        </div>
    <?php endforeach; ?>
   

</div>


<div id="flight-modal" class="modal" style="display: none;">
<span class="close">&times;</span>
    <div class="modal-content">
     
        <table>
            <tr>
                <td><strong>Origin</strong></td>
                <td id="modal-origin"></td>
                <td><strong>Destination</strong></td>
                <td id="modal-destination"></td>
            </tr>
            <tr>
                <td><strong>Departure Time</strong></td>
                <td id="modal-departure"></td>
                <td><strong>Arrival Time</strong></td>
                <td id="modal-arrival"></td>
            </tr>
            <tr>
                <td><strong>Class</strong></td>
                <td id="modal-class"></td>
                <td><strong>Type</strong></td>
                <td id="modal-type"></td>
            </tr>
        </table>
        <table>
            <tr>
                <td><strong>Layover</strong></td>
                <td id="modal-layover"></td>
            </tr>
            <tr>
                <td><strong>Price</strong></td>
                <td id="modal-price"></td>
            </tr>
        </table>
        <button id="confirm-button">Confirm</button>
    </div>
</div>

</body>
<script>
// Wait until the DOM is fully loaded
document.addEventListener('DOMContentLoaded', () => {
    const sortSelect = document.getElementById('flight-sort');
    const flightContainer = document.querySelector('.time');

    // Helper function to convert 12-hour format to 24-hour format
    function convertTo24Hour(time) {
        const [hours, minutes] = time.split(':');
        const [minutePart, ampm] = minutes.split(' ');
        let hour = parseInt(hours);
        const minute = parseInt(minutePart);

        if (ampm === 'PM' && hour !== 12) hour += 12; // Convert PM time
        if (ampm === 'AM' && hour === 12) hour = 0; // Convert 12 AM to 00:xx

        return `${String(hour).padStart(2, '0')}:${String(minute).padStart(2, '0')}`;
    }

    // Add event listener for sorting
    sortSelect.addEventListener('change', () => {
        const sortOption = sortSelect.value;

        // Collect all flight rows
        const flightRows = Array.from(flightContainer.querySelectorAll('.flight-row'));

        if (sortOption === 'lowest') {
            // Sort by lowest price (Economy Price)
            flightRows.sort((a, b) => {
                const priceA = parseFloat(a.querySelector('.price-container.economy .price').textContent.replace(/[^\d.]/g, ''));
                const priceB = parseFloat(b.querySelector('.price-container.economy .price').textContent.replace(/[^\d.]/g, ''));
                return priceA - priceB;
            });
        } else if (sortOption === 'earliest') {
            // Sort by earliest departure time
            flightRows.sort((a, b) => {
                const timeA = convertTo24Hour(a.querySelector('.flight-time').textContent.split(' - ')[0]);
                const timeB = convertTo24Hour(b.querySelector('.flight-time').textContent.split(' - ')[0]);
                return timeA.localeCompare(timeB);
            });
        }

        // Remove existing rows and re-add them in sorted order
        flightRows.forEach(row => flightContainer.appendChild(row));
    });
});

document.addEventListener('DOMContentLoaded', () => {
    const modal = document.getElementById('flight-modal');
    const modalClose = modal.querySelector('.close');
    const confirmButton = document.getElementById('confirm-button');
    const tripType = "<?php echo $tripType; ?>";
    const departDate = "<?php echo $departDate; ?>";
    const returnDate = "<?php echo $returnDate; ?>";

    // Retrieve flight data and isFirstFlight from local storage
    let flight1Data = JSON.parse(localStorage.getItem('flight1Data')) || null;
    let flight2Data = JSON.parse(localStorage.getItem('flight2Data')) || null;
    let isFirstFlight = JSON.parse(localStorage.getItem('isFirstFlight')) || true;

    // Show modal with flight details
    function showModal(flight, flightClass, tripType) {
        document.getElementById('modal-origin').textContent = flight['origin_code'];
        document.getElementById('modal-destination').textContent = flight['destination_code'];
        document.getElementById('modal-departure').textContent = flight['departure_time'];
        document.getElementById('modal-arrival').textContent = flight['arrival_time'];
        document.getElementById('modal-class').textContent = flightClass;
        document.getElementById('modal-type').textContent = tripType;
        document.getElementById('modal-layover').textContent = flight['layover'] ? flight['layover']['code'] : 'None';
        document.getElementById('modal-price').textContent = "PHP " + flight[flightClass.toLowerCase() + '_price'].toFixed(2);
        
        // Show the modal
        modal.style.display = 'block';
    }

    // Add event listeners to buttons
    document.querySelectorAll('.price.economy').forEach((button, index) => {
        button.addEventListener('click', () => {
            showModal(<?php echo json_encode($flights); ?>[index], 'Economy');
        });
    });

    document.querySelectorAll('.price.business').forEach((button, index) => {
        button.addEventListener('click', () => {
            showModal(<?php echo json_encode($flights); ?>[index], 'Business');
        });
    });

    // Close modal
    modalClose.addEventListener('click', () => {
        modal.style.display = 'none';
    });

    // Handle Confirm button click for both flights
    confirmButton.addEventListener('click', () => {
    console.log('Confirm button clicked'); // Confirm button click is registered

    // Log the current values of tripType and isFirstFlight
    console.log('Current tripType:', tripType);
    console.log('Current isFirstFlight:', isFirstFlight);

    if (tripType === 'roundtrip') {
        if (isFirstFlight === true) { // Check if isFirstFlight is true
            console.log('Collecting Flight 1 Data'); // Log that we're collecting flight 1 data

            // Collect flight 1 data
          /* flight1Data = {
                flight_date: departDate,
                origin_airport_id: flight1['origin_code'],
                destination_airport_id: flight1['destination_code'],
                departure_time: flight1['departure_time'],
                arrival_time: flight1['arrival_time'],
                layover_id: flight1['layover'] ? flight1['layover']['id'] : null,
                class_id: flightClass === 'Economy' ? 1 : 2,
                price: flightClass === 'Economy' ? flight1['economy_price'] : flight1['business_price'],
                aircraft_id: flight1['aircraft_id'],
                type_id: 1 // For outbound flight
                
            };*/

            console.log('Flight 1 Data:', flight1Data); // Log flight 1 data

            // Set isFirstFlight to false for the next confirmation
            isFirstFlight = false;
            console.log('isFirstFlight set to:', isFirstFlight); // Log the change

            modal.style.display = 'none'; // Close the modal
            console.log('Modal closed, reloading in 1 second...'); // Log before reload
            setTimeout(() => {
                window.location.reload(true);
            }, 1000); // Delay of 1000 milliseconds (1 second)

        } else {
            console.log('Collecting Flight 2 Data'); // Log that we're collecting flight 2 data

            // Collect flight 2 data when it's the second confirm click
            flight2Data = {
                flight_date: returnDate,
                origin_airport_id: flight2['origin_code'],
                destination_airport_id: flight2['destination_code'],
                departure_time: flight2['departure_time'],
                arrival_time: flight2['arrival_time'],
                layover_id: flight2['layover'] ? flight2['layover']['id'] : null,
                class_id: flightClass === 'Economy' ? 1 : 2,
                price: flightClass === 'Economy' ? flight2['economy_price'] : flight2['business_price'],
                aircraft_id: flight2['aircraft_id'],
                type_id: 2 // For round-trip return flight
            };

            console.log('Flight 2 Data:', flight2Data); // Log flight 2 data

            // Redirect to passengerinfo.php with both flight data
            window.location.href = 'passengerinfo.php?' + new URLSearchParams({...flight1Data, ...flight2Data}).toString();
        }
    } else {
        console.log('Collecting One-way Flight Data'); // Log that we're collecting one-way flight data

       /* // For one-way trips, collect flight data and redirect
        flight1Data = {
            flight_date: departDate,
            origin_airport_id: flight1['origin_code'],
            destination_airport_id: flight1['destination_code'],
            departure_time: flight1['departure_time'],
            arrival_time: flight1['arrival_time'],
            layover_id: flight1['layover'] ? flight1['layover']['id'] : null,
            class_id: flightClass === 'Economy' ? 1 : 2,
            price: flightClass === 'Economy' ? flight1['economy_price'] : flight1['business_price'],
            aircraft_id: flight1['aircraft_id'],
            type_id: 0 // For one-way flight
        };*/

        console.log('One-way Flight Data:', flight1Data); // Log one-way flight data

        // Redirect to passengerinfo.php with flight data
        window.location.href = 'passengerinfo.php?' + new URLSearchParams(flight1Data).toString();
    }
});

    // Close modal on clicking outside
    window.addEventListener('click', (e) => {
        if (e.target === modal) {
            modal.style.display = 'none';
        }
    });
});




</script>
</html>
