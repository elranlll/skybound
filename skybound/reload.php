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
    $returnDate = $_POST['return_date'];

    // Your existing logic to generate flights
    // For example, querying the database to get flight details
    $flights = []; // This should be populated with your flight data

    // Example query to fetch flights (you should replace this with your actual query)
    $query = "SELECT * FROM flight_details_view WHERE origin_airport_code = ? AND destination_airport_code = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param('ss', $origin_code, $destination_code);
    $stmt->execute();
    $result = $stmt->get_result();

    while ($row = $result->fetch_assoc()) {
        // Assuming you have a function to calculate prices and other details
        $flights[] = [
            'origin_code' => $row['origin_airport_code'],
            'destination_code' => $row['destination_airport_code'],
            'departure_time' => $row['departure_time'], // Adjust as necessary
            'arrival_time' => $row['arrival_time'], // Adjust as necessary
            'duration' => $row['duration'],
            'aircraft' => $row['aircraft_number'], // Adjust as necessary
            'layover' => $row['layover_status'] ? ['code' => $row['layover_airport_code']] : null,
            'economy_price' => calculatePrice($row['base_price'], $row['haul_id'], in_array(date('N', strtotime($departDate)), [6, 7]), 'economy'),
            'business_price' => calculatePrice($row['base_price'], $row['haul_id'], in_array(date('N', strtotime($departDate)), [6, 7]), 'business'),
        ];
    }

    // Output the flight rows as HTML
    foreach ($flights as $flight) {
        echo '<div class="flight-row">';
        echo '<div class="details-column">';
        echo '<div class="flight-route">' . htmlspecialchars($flight['origin_code']) . " &#8594; " . htmlspecialchars($flight['destination_code']) . '</div>';
        echo '<div class="flight-time">' . htmlspecialchars($flight['departure_time']) . " - " . htmlspecialchars($flight['arrival_time']) . '</div>';
        echo '</div>';
        echo '<div class="divider"></div>';
        echo '<div class="info-column">';
        echo '<div class="duration">Duration: ' . htmlspecialchars($flight['duration']) . '</div>';
        echo '<div class="airplane">Aircraft: ' . htmlspecialchars($flight['aircraft']) . '</div>';
        echo '</div>';
        echo '<div class="stop-column">';
        if ($flight['layover']) {
            echo '<div class="layover">' . htmlspecialchars($flight['layover']['code']) . '</div>';
            echo '<div class="stop">Layover</div>';
        }
        echo '</div>';
        echo '<button type="button" class="price economy"><div>Economy</div><div class="price">PHP ' . number_format($flight['economy_price'], 2) . '</div></button>';
        echo '<button type="button" class="price business"><div>Business</div><div class="price">PHP ' . number_format($flight['business_price'], 2) . '</div></button>';
        echo '</div>';
    }
}
?>