package com.example.pawntodb4app;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.scene.control.Alert;
import javafx.scene.control.ComboBox;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;
import javafx.stage.Stage;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class AddExtraToGameController {

    AddGameController rootController;

    @FXML
    private ComboBox<String> openingBox;

    @FXML
    private TextField endingField;

    @FXML
    private TextArea movesRecordArea;

    @FXML
    public void initialize() {
        loadOpenings();
    }

    private void loadOpenings() {
        ObservableList<String> options = FXCollections.observableArrayList();

        try {
            Connection connection = DataBaseConfig.connect();
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery("SELECT name FROM PTDB4.opening_name");
            while (resultSet.next()) {
                String item = resultSet.getString("name");
                options.add(item);
            }
            openingBox.setItems(options);

        } catch (SQLException ex) {
            showErrorAlert("Błąd", "Nie można nawiązać połączenia z bazą danych");
            ex.printStackTrace();
        }
    }

    @FXML
    public void handleAddButton() {
        rootController.setEnding(endingField.getText());
        rootController.setRecord(movesRecordArea.getText());
        rootController.setOpeningName(openingBox.getValue());
        showSuccessAlert("Pomyslnie dodano", "Pomyślnie dodano dodatkowe szczegóły gry");
        Stage stage = (Stage) openingBox.getScene().getWindow();
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

    public void setRootController(AddGameController rootController) {
        this.rootController = rootController;
    }
}