package com.example.pawntodb4app;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.stage.Stage;
import javafx.util.StringConverter;
import javafx.util.converter.FormatStringConverter;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public class AddGameController {

    ObservableList<String> result;
    ObservableList<String> tournaments;
    @FXML
    private Button backButton;

    @FXML
    private TextField blackPlayerImie;

    @FXML
    private TextField blackPlayerNazwisko;

    @FXML
    private DatePicker dateOfMatch;

    @FXML
    private Button gameRecordButton;

    @FXML
    private ChoiceBox<String> resultChoiceBox;
    @FXML
    private ChoiceBox<String> tournamentChoice;
    @FXML
    private Button gameAddButton;

    @FXML
    private TextField whitePlayerImie;

    @FXML
    private TextField whitePlayerNazwisko;
    @FXML
    void handleAddButton(ActionEvent event) {
        String query = "insert into match_insert_view" +
                "values ('?','?','?','?','?','?','?')"; //imieB, nazwB,imieCz,nazwCz, wynik, data, turniej
        String firstNameW = whitePlayerImie.getText();
        String lastNameW = whitePlayerNazwisko.getText();
        String firstNameB = blackPlayerImie.getText();
        String lastNameB = blackPlayerNazwisko.getText();
        if (firstNameW == null || firstNameW.isEmpty()) {
            showErrorAlert("Błąd", "Imię Gracza Białego nie może być puste");
            return;
        }

        if (lastNameW == null || lastNameW.isEmpty()) {
            showErrorAlert("Błąd", "Nazwisko Gracza Białego nie może być puste");
            return;
        }
        if (firstNameB == null || firstNameB.isEmpty()) {
            showErrorAlert("Błąd", "Imię Gracza Czarnego nie może być puste");
            return;
        }

        if (lastNameB == null || lastNameB.isEmpty()) {
            showErrorAlert("Błąd", "Nazwisko Gracza Czarnego nie może być puste");
            return;
        }
        String res = resultChoiceBox.getValue();
        if(res == null ) {
            showErrorAlert("Błąd", "Musisz wprowadzić wynik meczu");
            return;
        }
        LocalDate selectedDate = dateOfMatch.getValue();
        if(selectedDate == null) {
            showErrorAlert("Błąd", "Musisz wprowadzić datę meczu");
            return;
        }
        String formatted = selectedDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        System.out.println(formatted);
        String tournament = tournamentChoice.getValue();
        if (tournament == null || tournament.isEmpty())
                tournament= "null";
        try (Connection con = DataBaseConfig.connect();
             PreparedStatement pst = con.prepareStatement(query)) {

            pst.setString(1, firstNameW);
            pst.setString(2, lastNameW);
            pst.setString(3, firstNameB);
            pst.setString(4, lastNameB);
            pst.setString(5,res);
            pst.setString(6,formatted);
            pst.setString(7,tournament);

            try (ResultSet rs = pst.executeQuery()) {
                showSuccessAlert("Sukces!", "Pomyślnie dodano mecz");
            }

        } catch (SQLException ex) {
            showErrorAlert("Błąd", "Nie można nawiązać połączenia z bazą danych");
            ex.printStackTrace();
        }
    }
    @FXML
    void handleBackButton(ActionEvent event) throws IOException {
        FXMLLoader loader = new FXMLLoader(getClass().getResource("mainMenu.fxml"));
        Parent root = loader.load();
        Stage stage = (Stage) backButton.getScene().getWindow();
        stage.setScene(new Scene(root, 320, 240));
    }

    @FXML
    void handleGameRecordButton(ActionEvent event) {

    }
    public void initialize() {
        result = FXCollections.observableArrayList();
        tournaments = FXCollections.observableArrayList();
        try (Connection con = DataBaseConfig.connect()) {
            String query = "SELECT unnest(enum_range(NULL::PTDB4.match_result))";
            try (Statement statement = con.createStatement();
                 ResultSet resultSet = statement.executeQuery(query)) {
                while (resultSet.next()) {
                    String item = resultSet.getString("unnest");
                    result.add(item);
                }
            }

        } catch (SQLException ex) {
            showErrorAlert("Błąd", "Nie można nawiązać połączenia z bazą danych");
            ex.printStackTrace();
        }

        try (Connection con = DataBaseConfig.connect()) {
            String query = "SELECT name from PTDB4.tournaments";
            try (Statement statement = con.createStatement();
                 ResultSet resultSet = statement.executeQuery(query)) {
                while (resultSet.next()) {
                    String item = resultSet.getString("name");
                    tournaments.add(item);
                }
            }

        } catch (SQLException ex) {
            showErrorAlert("Błąd", "Nie można nawiązać połączenia z bazą danych");
            ex.printStackTrace();
        }
        resultChoiceBox.setItems(result);
        tournamentChoice.setItems(tournaments);
    }
    private void showErrorAlert(String title, String message) {
        Alert alert = new Alert(Alert.AlertType.ERROR);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }
    private void showSuccessAlert(String title, String message) {
        Alert alert = new Alert(Alert.AlertType.INFORMATION);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }
}