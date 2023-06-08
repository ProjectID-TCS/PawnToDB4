package com.example.pawntodb4app;


import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.chart.CategoryAxis;
import javafx.scene.chart.LineChart;
import javafx.scene.chart.NumberAxis;
import javafx.scene.chart.XYChart;
import javafx.scene.control.*;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.stage.Modality;
import javafx.stage.Stage;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Optional;


public class PlayerDetailsController {
    private int playerId;
    @FXML
    public LineChart<String, Number> eloChart;
    private CategoryAxis xAxis;
    private NumberAxis yAxis;
    @FXML
    private Label firstNameField;

    @FXML
    private Label lastNameField;

    @FXML
    private Label groupField;

    @FXML
    private Label maxElo;

    @FXML
    private Button deletePlayerButton;
    @FXML
    private Button closeButton;
    @FXML
    void deletePlayer(ActionEvent event) {
        showInfoAlert("Czy jesteś pewny?", "Tej akcji nie można cofnąć.");
    }
    void delete(){
        try {
            Connection connection = DataBaseConfig.connect();
            Statement statement = connection.createStatement();
            int rows = statement.executeUpdate("update ptdb4.players " +
                    "set first_name = '', last_name = ''" +
                    "WHERE id = " + playerId);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void setPlayer(Player player) {
        firstNameField.setText(player.getFirstName());
        lastNameField.setText(player.getLastName());
        groupField.setText(String.valueOf(player.getGroupId()));
        maxElo.setText(player.getMaxElo());
        playerId = player.getId();
    }

    public void loadChartData(int playerId) {
        xAxis = new CategoryAxis();
        yAxis = new NumberAxis();

        eloChart.setTitle("Historia ELO");
        xAxis.setLabel("Data");
        yAxis.setLabel("ELO");
        ObservableList<XYChart.Data<String, Number>> eloData = FXCollections.observableArrayList();
        try {
            Connection connection = DataBaseConfig.connect();
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery("SELECT acquired_on, elo " +
                    "FROM ptdb4.elo " +
                    "WHERE player_id = " + playerId);
            while (resultSet.next()) {
                String date = resultSet.getString("acquired_on");
                int elo = resultSet.getInt("elo");
                eloData.add(new XYChart.Data<>(date, elo));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        XYChart.Series<String, Number> series = new XYChart.Series<>(eloData);
        series.setName("ELO");

        eloChart.getData().add(series);
    }


    @FXML
    public void handleCloseButton() {
        Stage stage = (Stage) firstNameField.getScene().getWindow();
        stage.close();
    }
    private void showInfoAlert(String title, String message) {
        Alert alert = new Alert(Alert.AlertType.WARNING);
        alert.initModality(Modality.APPLICATION_MODAL);
        alert.initOwner(deletePlayerButton.getScene().getWindow());
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        Button cancelButton = new Button("Wróć");
        ButtonBar buttonBar = (ButtonBar) alert.getDialogPane().lookup(".button-bar");
        buttonBar.getButtons().add(cancelButton);
        cancelButton.setOnAction(event -> alert.close());
        Optional<ButtonType> res = alert.showAndWait();
        if(res.isPresent()) {
            if (res.get() == ButtonType.OK) {
                delete();
                showSuccessAlert("Usunięto", "Wskazany gracz został usunięty z bazy danych");
                firstNameField.setText("");
                lastNameField.setText("");
                groupField.setText("");
            }
        }

    }
    private void showSuccessAlert(String title, String message) {
        Alert alert = new Alert(Alert.AlertType.INFORMATION);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }
}
