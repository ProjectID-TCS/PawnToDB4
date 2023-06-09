package com.example.pawntodb4app;

import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Alert;
import javafx.scene.control.Button;
import javafx.scene.control.DatePicker;
import javafx.scene.control.TextField;
import javafx.stage.Stage;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public class SearchGameController {

    @FXML
    private Button backButton;

    @FXML
    private TextField blackPlayerImie;

    @FXML
    private TextField blackPlayerNazwisko;

    @FXML
    private DatePicker dateOfMatch;

    @FXML
    private Button gameSearchButton;

    @FXML
    private TextField whitePlayerImie;

    @FXML
    private TextField whitePlayerNazwisko;

    @FXML
    public void handleSearchButton() throws IOException {
        String firstNameW = whitePlayerImie.getText();
        String lastNameW = whitePlayerNazwisko.getText();
        String firstNameB = blackPlayerImie.getText();
        String lastNameB = blackPlayerNazwisko.getText();
        if (firstNameW.equals(firstNameB) && lastNameB.equals(lastNameW)) {
            showErrorAlert("Błąd", "Gracze muszą być różni");
            return;
        }
        boolean isWempty = ((firstNameW == null || firstNameW.isEmpty())
                || (lastNameW == null || lastNameW.isEmpty()));
        boolean isBempty = ((firstNameB == null || firstNameB.isEmpty()) || (lastNameB == null || lastNameB.isEmpty()));

        if (isWempty && isBempty) {
            showErrorAlert("Błąd", "Gracz musi miec wszystkie informacje wpisane");
            return;
        }

        LocalDate selectedDate = dateOfMatch.getValue();
        if (selectedDate == null) {
            showErrorAlert("Błąd", "Musisz wprowadzić datę meczu");
            return;
        }
        String formatted = selectedDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));

        if (isWempty) {
            searchBlack(firstNameB, lastNameB, formatted);
            return;
        }
        if (isBempty) {
            searchWhite(firstNameW, lastNameW, formatted);
            return;
        }
        searchDirect(firstNameW, lastNameW, firstNameB, lastNameB, formatted);
    }

    public void searchDirect(String firstNameW, String lastNameW, String firstNameB, String lastNameB, String date) throws
            IOException {
        String blackId = "0";
        String whiteId = "0";
        try (Connection con = DataBaseConfig.connect()) {
            String queryId = "SELECT p.id " +
                    "FROM PTDB4.players p " +
                    "WHERE p.first_name = ? AND p.last_name = ?";
            PreparedStatement pstW = con.prepareStatement(queryId);

            pstW.setString(1, firstNameW);
            pstW.setString(2, lastNameW);
            ResultSet WSet = pstW.executeQuery();
            if (!WSet.next()) {
                showErrorAlert("Błąd", "Gracz biały nie istnieje");
                return;
            }
            whiteId = WSet.getString(1);

            PreparedStatement pstB = con.prepareStatement(queryId);
            pstB.setString(1, firstNameB);
            pstB.setString(2, lastNameB);
            ResultSet BSet = pstB.executeQuery();
            if (!BSet.next()) {
                showErrorAlert("Błąd", "Gracz czarny nie istnieje");
                return;
            }
            blackId = BSet.getString(1);

            String paringQuery = "select p.tournament_id, p.result, p.id_record "
                    + "from ptdb4.pairings p where " +
                    "white = (?)::int and black = (?)::int and match_date = (?)::date";
            PreparedStatement pstPair = con.prepareStatement(paringQuery);
            pstPair.setString(1, whiteId);
            pstPair.setString(2, blackId);
            pstPair.setString(3, date);
            ResultSet pairingInformation = pstPair.executeQuery();

            FXMLLoader loader = new FXMLLoader(getClass().getResource("gameSearchDetails.fxml"));
            Parent root = loader.load();

            GameSearchDetailsController controller = loader.getController();
            controller.setPlayers(firstNameW, lastNameW, firstNameB, lastNameB, date);
            Stage stage = new Stage();
            stage.setTitle("Szczegóły gry");
            stage.setScene(new Scene(root, 1000, 700));
            stage.show();

        } catch (SQLException ex) {
            showErrorAlert("Błąd", "Nie można nawiązać połączenia z bazą danych");
            ex.printStackTrace();
        }
    }

    public void searchWhite(String firstNameW, String lastNameW, String date) {

    }

    public void searchBlack(String firstNameB, String lastNameB, String date) {

    }

    @FXML
    public void handleBackButton() throws IOException {
        FXMLLoader loader = new FXMLLoader(getClass().getResource("mainMenu.fxml"));
        Parent root = loader.load();

        Stage stage = (Stage) backButton.getScene().getWindow();
        stage.setScene(new Scene(root, 320, 240));
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
