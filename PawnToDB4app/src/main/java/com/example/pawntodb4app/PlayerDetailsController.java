package com.example.pawntodb4app;

import javafx.fxml.FXML;
import javafx.scene.control.Label;
import javafx.stage.Stage;

public class PlayerDetailsController {

    @FXML
    private Label idField;

    @FXML
    private Label firstNameField;

    @FXML
    private Label lastNameField;

    @FXML
    private Label groupField;

    public void setPlayer(Player player) {
        idField.setText(String.valueOf(player.getId()));
        firstNameField.setText(player.getFirstName());
        lastNameField.setText(player.getLastName());
        groupField.setText(String.valueOf(player.getGroupId()));
    }

    @FXML
    public void handleCloseButton() {
        Stage stage = (Stage) idField.getScene().getWindow();
        stage.close();
    }
}
