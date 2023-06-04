package com.example.pawntodb4app;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.TextField;
import javafx.stage.Stage;

import java.io.IOException;

public class AddGameController {


    @FXML
    private Button backButton;

    @FXML
    private TextField blackPlayerField;

    @FXML
    private Button gameRecordButton;

    @FXML
    private TextField whitePlayerFielld;

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


}