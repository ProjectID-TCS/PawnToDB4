package com.example.pawntodb4app;

import javafx.application.Platform;
import javafx.beans.property.BooleanProperty;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.collections.ObservableMap;
import javafx.collections.transformation.FilteredList;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.geometry.Insets;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;
import javafx.util.Pair;
import org.controlsfx.control.RangeSlider;

import java.io.IOException;
import java.sql.*;
import java.util.*;

public class AddTournamentController {
    private int first=0;
    private int eloLow=1500;
    private int eloHigh=3000;
    private int graczeNum=0;
    VBox root;
    ObservableList<String> options;
    List<Integer> participants;
    ListView<HBox> players;
    List<ComboBox<String>> wyniki;
    Map<Integer,Integer> playerIDs;
    List<Pair<Integer,Integer>> pairings;
    Map<Integer,String> playerInfos;
    @FXML
    private TextField countryField;
    @FXML
    private TextField cityField;

    @FXML
    private TextField namefield;

    @FXML
    private Label graczeLabel;

    @FXML
    private TextField noplayersField;

    @FXML
    private TextField streetField;

    @FXML
    private TextField streetNrField;
    @FXML
    private VBox sceneDraft;
    @FXML
    private Button addButton;

    @FXML
    private ChoiceBox<String> typeCheckBox;
    @FXML
    private GridPane sceneGrid;

    @FXML
    private Label eloHighLabel;

    @FXML
    private Label eloLowLabel;
    @FXML
    void addTournament(ActionEvent event) {
        if(noplayersField.textProperty().toString().equals("")){
            showAlert("STOP","Podaj liczbę graczy");
            return;
        }
        if(noplayersField.textProperty().toString().equals("1")){
            showAlert("STOP","turniej musi mieć co najmniej 2 graczy");
            return;
        }
        if(first==0)
        {
            first=1;
            addPlayers();
            addButton.setText("Utwórz turniej");
        }
        else if(first ==1){
            createTournament();
            first =2;
            addButton.setText("Dalej");
        }
        else{
            insertToDB();
        }
    }

    private void insertToDB(){
        //getid from db of newly added tournament
        String beginTrans = "Begin";
        String cityAdder = "insert into cities (city,street,street_number) values(?,?,?)";
        String cityIDGetter = "select id from cities where city = ? and street = ? and street_number = ?";
        String placeAdder = "insert into places (country, city_id) values (?,?)";
        String placeIDGetter = "select id from places where country = ? and city_id = ?";

        String tournamentAdder =
                "insert into tournaments (name, format, place, start_date, end_date)" +
                "values (?,?,?,?)";
        String tournamentGetter = "select id from tournaments where name = ? and format = ? and place = ?  and start_ date = ? and end_date = ?";
        List<String> games = addGames(id); //<- result;
    }
    List<String> addGames(int id){
        List<String> games = new ArrayList<>();
        ObservableList<HBox> tmp = ((ListView<HBox>) root.getChildren().get(1)).getItems();
        for(int i=0; i<tmp.size();i++) {
            Integer plW= pairings.get(i).getKey();
            Integer plB = pairings.get(i).getValue();
            System.out.println(plW + " " + plB);
            String res;
            if((wyniki.get(i).getValue()).equals("White")){
                res = "insert into ptdb4.pairings (white, black,tournament_id,result) values" +
                        "(" + plW.toString() + "," + plB.toString() + "," + String.valueOf(id) + ",W)";_
            }
            else if((wyniki.get(i).getValue()).equals("Draw")){
                res = "insert into ptdb4.pairings (white, black,tournament_id,result) values" +
                        "(" + plW.toString() + "," + plB.toString() + "," + String.valueOf(id) + ",D)";
            }
            else{
                res = "insert into ptdb4.pairings (white, black,tournament_id,result) values" +
                        "(" + plW.toString() + "," + plB.toString() + "," + String.valueOf(id) + ",B)";
            }
            games.add(res);
        }
        return games;
    }
    private void createTournament(){
        participants = new ArrayList<>();
        for(int i=0;i< players.getItems().size();i++){
            CheckBox box = (CheckBox) players.getItems().get(i).getChildren().get(0);
            if(box.selectedProperty().get()) {
                System.out.println(playerIDs.get(i));
                participants.add(playerIDs.get(i));
                refactorScene();
            }
        }
    }
    private void refactorScene(){
        root = new VBox();
        root.getChildren().add(new Label("Wybierz wyniki spotkań"));
        sceneDraft.getChildren().set(1,root);
        ListView<HBox> wyniki = new ListView<>();
        fill(wyniki);
        root.getChildren().add(wyniki);
    }
    private void fill(ListView<HBox> matches){
        wyniki = new ArrayList<>();
        pairings = new ArrayList<>();
        for( int i=0;i<participants.size();i++)
            for(int j=i+1;j<participants.size();j++)
            {
                HBox box = new HBox();
                box.setSpacing(20);
                box.setPadding(new Insets(20));
                int x = (int) (Math.random()%1000);
                ComboBox<String> results = new ComboBox<String>();
                wyniki.add(results);
                results.getItems().addAll(Arrays.asList("White","Draw","Black"));
                if(x%2==1) {
                    box.getChildren().add(new Label(playerInfos.get(playerIDs.get(i))));
                    box.getChildren().add(results);
                    box.getChildren().add(new Label(playerInfos.get(playerIDs.get(j))));
                    pairings.add(new Pair<>(playerIDs.get(i),playerIDs.get(j)));
                }
                else {
                    box.getChildren().add(new Label(playerInfos.get(playerIDs.get(j))));
                    box.getChildren().add(results);
                    box.getChildren().add(new Label(playerInfos.get(playerIDs.get(i))));
                    pairings.add(new Pair<>(playerIDs.get(j),playerIDs.get(i)));
                }
                matches.getItems().add(box);
            }
    }
    private void addPlayers(){
        playerIDs = new HashMap<>();
        playerInfos = new HashMap<>();
        players = new ListView<>();
        if(!noplayersField.textProperty().toString().equals(""))
            graczeNum = Integer.parseInt(noplayersField.getText());
        String query = "SELECT * "+
                "FROM PTDB4.players p " +
                "WHERE p.max_elo < ? " +
                "and p.max_elo > ?";
        try (Connection con = DataBaseConfig.connect();
             PreparedStatement pst = con.prepareStatement(query)) {

            pst.setInt(1, eloHigh);
            pst.setInt(2, eloLow);
            int counter =0;
            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) {
                    playerIDs.put(counter,rs.getInt("id"));
                    counter++;
                    HBox player = new HBox();
                    Label info = new Label(rs.getString("first_name")+ " " + rs.getString("last_name"));
                    playerInfos.put(rs.getInt("id"),info.getText());
                    CheckBox isChosen = new CheckBox();
                    isChosen.setOnAction(e  -> {if(chosen(isChosen.selectedProperty()))
                        isChosen.selectedProperty().set(false);});
                    player.getChildren().add(isChosen);
                    player.getChildren().add(info);
                    player.setSpacing(10);
                    player.setPadding(new Insets(10));
                    players.getItems().add(player);
                }
            }
        } catch (SQLException ex) {
            showAlert("Błąd", "Nie można nawiązać połączenia z bazą danych");
            ex.printStackTrace();
        }
        sceneDraft.getChildren().add(players);
    }
    private boolean chosen(BooleanProperty change){
        if(graczeNum == 0 && change.get()) {
            showAlert("Stop", "Wybrałeś już wszystkich graczy");
            return true;
        }
        if(change.get())
            graczeNum--;
        else
            graczeNum++;
        noplayersField.textProperty().set(String.valueOf(graczeNum));
        return false;
    }
    private RangeSlider slider;
    public void initialize(){
        fillTypes();
        slider = new RangeSlider(1500,3000,2000,2700);
        slider.setShowTickLabels(true);
        slider.setShowTickMarks(true);
        slider.setMajorTickUnit(300);
        slider.setMinorTickCount(20);
        slider.setBlockIncrement(100);
        sceneGrid.add(slider,0,1);
        eloLowLabel.setText("1500");
        eloHighLabel.setText("2700");
        slider.highValueProperty().addListener((obs,oldVal,newVal) ->
        {
            eloHigh = (newVal.intValue() / 10) * 10;
            eloHighLabel.setText(String.valueOf(eloHigh));
            recalculatePlayers();});
        slider.lowValueProperty().addListener((obs,oldVal,newVal) ->
        {
            eloLow = (newVal.intValue() / 10) * 10;
            eloLowLabel.setText(String.valueOf(eloLow));
            recalculatePlayers();
        });
    }
    private void recalculatePlayers(){
        String query = "SELECT count(*) as c "+
                "FROM PTDB4.players p " +
                "WHERE p.max_elo <  ? " +
                 "and p.max_elo > ?";
        try (Connection con = DataBaseConfig.connect();
             PreparedStatement pst = con.prepareStatement(query)) {
            pst.setInt(1, eloHigh);
            pst.setInt(2, eloLow);
            try (ResultSet rs = pst.executeQuery()) {
                if(rs.next()) {
                    graczeLabel.setText(rs.getInt("c") + " graczy w bazie");
                }
            }

        } catch (SQLException ex) {
            showAlert("Błąd", "Nie można nawiązać połączenia z bazą danych");
            ex.printStackTrace();
        }
    }
    private void fillTypes(){
        options = FXCollections.observableArrayList();
        try (Connection con = DataBaseConfig.connect()) {
            String query = "SELECT name FROM PTDB4.FORMATS";
            try (Statement statement = con.createStatement();
                 ResultSet resultSet = statement.executeQuery(query)) {
                while (resultSet.next()) {
                    String item = resultSet.getString("name");
                    options.add(item);
                }
            }

        } catch (SQLException ex) {
            showAlert("Błąd", "Nie można nawiązać połączenia z bazą danych");
            ex.printStackTrace();
        }
        typeCheckBox.setItems(options);
    }
    private void showAlert(String title, String message) {
        Alert alert = new Alert(Alert.AlertType.ERROR);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }
}