package com.example.pawntodb4app;

import javafx.fxml.FXML;
import javafx.scene.control.Alert;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextArea;
import javafx.stage.Stage;

public class GameSearchDetailsController {

    private Match match;

    @FXML
    private Label gameResultLabel;

    @FXML
    private Label blackPlayerImie;

    @FXML
    private Label blackPlayerNazwisko;

    @FXML
    private Label dateOfMatch;

    @FXML
    private Label tournamentNameLabel;

    @FXML
    private Label openingLabel;

    @FXML
    private Label endingLabel;

    @FXML
    private TextArea gameRecordTxt;

    @FXML
    private Button closeButton;

    @FXML
    private Label whitePlayerImie;

    @FXML
    private Label whitePlayerNazwisko;

    public void setMatch(Match match) {
        this.match = match;
    }

    public void setPlayers(String firstNameW, String lastNameW, String firstNameB, String lastNameB, String date) {
        blackPlayerImie.setText(firstNameB);
        blackPlayerNazwisko.setText(lastNameB);
        whitePlayerNazwisko.setText(lastNameW);
        whitePlayerImie.setText(firstNameW);
        dateOfMatch.setText(date);
    }

    public void setGameInformation(String opening, String ending, String result) {
        openingLabel.setText(opening);
        endingLabel.setText(ending);
        gameResultLabel.setText(result);
    }

    public void setGameRecordTxt(String gameRecord) {
        gameRecordTxt.setText(gameRecord);
    }

    @FXML
    public void handleCloseButton() {
        Stage stage = (Stage) blackPlayerImie.getScene().getWindow();
        stage.close();
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
