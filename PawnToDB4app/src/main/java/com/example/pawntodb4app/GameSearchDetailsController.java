package com.example.pawntodb4app;

import javafx.fxml.FXML;
import javafx.scene.control.Label;

public class GameSearchDetailsController {

    Match match;

    @FXML
    private Label gameResult;

    @FXML
    private Label blackPlayerImie;

    @FXML
    private Label blackPlayerNazwisko;

    @FXML
    private Label dateOfMatch;

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
}
