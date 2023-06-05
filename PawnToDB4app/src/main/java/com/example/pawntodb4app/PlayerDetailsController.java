package com.example.pawntodb4app;


import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.scene.chart.CategoryAxis;
import javafx.scene.chart.LineChart;
import javafx.scene.chart.NumberAxis;
import javafx.scene.chart.XYChart;
import javafx.scene.control.Label;
import javafx.stage.Stage;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;


public class PlayerDetailsController {

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

    public void setPlayer(Player player) {
        firstNameField.setText(player.getFirstName());
        lastNameField.setText(player.getLastName());
        groupField.setText(String.valueOf(player.getGroupId()));
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
}
