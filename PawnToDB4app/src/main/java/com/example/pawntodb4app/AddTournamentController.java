package com.example.pawntodb4app;

import javafx.application.Platform;
import javafx.beans.property.BooleanProperty;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
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
import java.sql.Date;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.*;

public class AddTournamentController {

    Connection con;
    private int a = 103;
    private int first=0;
    private int eloLow=1500;
    private int eloHigh=3000;
    private int graczeNum=0;
    private int cityID;
    private int placeID;
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
    private Label noPlayersLabel;

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
        if (countryField == null || countryField.getText().isEmpty()) {
            showAlert("Błąd", "Podaj kraj, w którym odbywa się turniej");
            return;
        }

        if (cityField == null || cityField.getText().isEmpty()) {
            showAlert("Błąd", "Podaj miasto, w którym odbywa się turniej");
            return;
        }
        String res = typeCheckBox.getValue();
        if (res == null) {
            showAlert("Błąd", "Musisz wprowadzić format turnieju");
            return;
        }
        if(first==0)
        {
            first=1;
            addPlayers();
            addButton.setText("Utwórz turniej");
            namefield.setEditable(false);
            noplayersField.setEditable(false);
            cityField.setEditable(false);
            countryField.setEditable(false);
            streetField.setEditable(false);
            streetNrField.setEditable(false);
            slider.setDisable(true);
            typeCheckBox.setDisable(true);
            noPlayersLabel.setText("Zostało do wybrania:");
        }
        else if(first ==1){
            createTournament();
            first =2;
            addButton.setText("Dalej");
        }
        else if(first ==2){
            insertToDB();
            showSuccessAlert("Gratulacje", "Dodałeś swój pierwszy turniej!");
            addButton.setText("Zamknij");
            first = 3;
        }
        else
        {
            FXMLLoader loader = new FXMLLoader(getClass().getResource("mainMenu.fxml"));
            Parent root = null;
            try {
                root = loader.load();
            } catch (IOException e) {
                throw new RuntimeException(e);
            }

            Stage stage = (Stage) addButton.getScene().getWindow();
            stage.setScene(new Scene(root, 320, 240));
        }
    }

    private void insertToDB(){
        int ID=0;
        //getid from db of newly added tournament
        String beginTrans = "Begin";
        String commitTrans = "Commit";
        String cityAdder = "insert into ptdb4.cities (id,city,street,street_number) values(?,?,?,?)";

        String placeAdder = "insert into ptdb4.places (id,country, city_id) values (?,?,?)";

        String formatIDGetter = "select id from ptdb4.formats where name = ?";
        String tournamentAdder =
                "insert into ptdb4.tournaments (id,name, format, place, start_date, end_date)" +
                "values (?,?,?,?,?,?)";
        String tournamentGetter = "select id from ptdb4.tournaments where name = ? and format = ? and place = ?  and start_ date = ? and end_date = ?";
        con  = DataBaseConfig.connect();
        try {
        con.setAutoCommit(false);
             PreparedStatement transBegin = con.prepareStatement(beginTrans);
            transBegin.execute();
            if(placeFinder() == -1){
                if(cityFinder() == -1) {
                    PreparedStatement cityAdd = con.prepareStatement(cityAdder);
                    cityAdd.setInt(1, a);
                    cityAdd.setString(2, cityField.getText());
                    cityAdd.setString(3, streetField.getText());
                    cityAdd.setString(4, streetNrField.getText());
                    cityAdd.executeUpdate();
                }
                cityID = cityFinder();
                PreparedStatement placeAdd = con.prepareStatement(placeAdder);
                placeAdd.setInt(1, a);
                placeAdd.setString(2, countryField.getText());
                placeAdd.setInt(3, cityID);
                placeAdd.executeUpdate();
             }

            placeID = placeFinder();
            PreparedStatement formatGet = con.prepareStatement(formatIDGetter);
            formatGet.setString(1, typeCheckBox.getValue());
            ResultSet formatIDResult = formatGet.executeQuery();
            formatIDResult.next();
            PreparedStatement tournamentAdd = con.prepareStatement(tournamentAdder);
            tournamentAdd.setInt(1,a);
            tournamentAdd.setString(2, namefield.getText());
            tournamentAdd.setInt(3, formatIDResult.getInt("id"));
            tournamentAdd.setInt(4, placeID);
            LocalDate begDate = LocalDate.of(LocalDate.now().getYear()-1, 7, 1);
            LocalDate endDate = begDate.plus(1, ChronoUnit.WEEKS);
            tournamentAdd.setDate(5,java.sql.Date.valueOf(begDate));
            tournamentAdd.setDate(6,java.sql.Date.valueOf(endDate));
            tournamentAdd.executeUpdate();
            PreparedStatement tournamentGet = con.prepareStatement(tournamentGetter);
            ID = a;
            a++;
        } catch (SQLException ex) {
            ex.printStackTrace();
            showAlert("Błąd", "Nie można nawiązać połączenia z bazą danych");
            rollback();
        }
                List<String> games = addGames(ID); //<- result;
        for(String game : games){
            try {
                PreparedStatement playerAdd = con.prepareStatement(game);
                playerAdd.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
                showAlert("Błąd","Nie udało się dodać partii");
                rollback();
            }
        }
        try{
//            PreparedStatement committing = con.prepareStatement(commitTrans);
            con.commit();
//            committing.execute();
        } catch (SQLException e) {
            e.printStackTrace();
            showAlert("Błąd", "Coś poszło nie tak...");
            rollback();
        }
    }
    int placeFinder(){
    placeID = -1;
        String placeIDGetter = "select id from ptdb4.places where country = ? and city_id = ?";
        try {
            PreparedStatement cityGet = con.prepareStatement(placeIDGetter);
            cityGet.setString(1, countryField.getText());
            cityGet.setInt(2, cityID);
            ResultSet cityIDResult = cityGet.executeQuery();
            if(cityIDResult.next())
                placeID = cityIDResult.getInt("id");
        }
        catch (SQLException sqlException){
            sqlException.printStackTrace();
            rollback();
        }
    return placeID;
    }
    int cityFinder(){
        cityID = -1;
        String cityIDGetter = "select id from ptdb4.cities where city = ? and street = ? and street_number = ?";
        try{
            PreparedStatement cityGet = con.prepareStatement(cityIDGetter);
            cityGet.setString(1, cityField.getText());
            cityGet.setString(2, streetField.getText());
            cityGet.setString(3, streetNrField.getText());
            ResultSet cityIDResult = cityGet.executeQuery();
            if(cityIDResult.next())
                cityID = cityIDResult.getInt("id");

        }
        catch (SQLException sqlException){
            sqlException.printStackTrace();
            rollback();
        }
        return cityID;
    }

    List<String> addGames(int id){
        List<String> games = new ArrayList<>();
        ObservableList<HBox> tmp = ((ListView<HBox>) root.getChildren().get(1)).getItems();
        for(int i=0; i<tmp.size();i++) {
            Integer plW= pairings.get(i).getKey();
            Integer plB = pairings.get(i).getValue();
            String res;
            if((wyniki.get(i).getValue()).equals("White")){
                res = "insert into ptdb4.pairings (white, black,tournament_id,result) values" +
                        "(" + plW.toString() + "," + plB.toString() + "," + String.valueOf(id) + ",CAST('W' AS ptdb4.match_result))";
            }
            else if((wyniki.get(i).getValue()).equals("Draw")){
                res = "insert into ptdb4.pairings (white, black,tournament_id,result) values" +
                        "(" + plW.toString() + "," + plB.toString() + "," + String.valueOf(id) + ",CAST('D' AS ptdb4.match_result))";
            }
            else{
                res = "insert into ptdb4.pairings (white, black,tournament_id,result) values" +
                        "(" + plW.toString() + "," + plB.toString() + "," + String.valueOf(id) + ",CAST('B' AS ptdb4.match_result))";
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
                participants.add(playerIDs.get(i));
                refactorScene();
            }
        }
    }
    private void rollback(){
        String nonono = "rollback";
        try{
            PreparedStatement rollingBack = con.prepareStatement(nonono);
            rollingBack.execute();
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
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
                    box.getChildren().add(new Label(playerInfos.get(participants.get(i))));
                    box.getChildren().add(results);
                    box.getChildren().add(new Label(playerInfos.get(participants.get(j))));
                    pairings.add(new Pair<>(participants.get(i),participants.get(j)));
                }
                else {
                    box.getChildren().add(new Label(playerInfos.get(participants.get(j))));
                    box.getChildren().add(results);
                    box.getChildren().add(new Label(playerInfos.get(participants.get(i))));
                    pairings.add(new Pair<>(participants.get(j),participants.get(i)));
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
                "and p.max_elo > ? order by first_name, last_name";
         try (Connection con = DataBaseConfig.connect()) {
             PreparedStatement pst = con.prepareStatement(query);
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
        getID();
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
        noplayersField.textProperty().addListener(new ChangeListener<String>() {
            @Override
            public void changed(ObservableValue<? extends String> observable, String oldValue,
                                String newValue) {
                if (!newValue.matches("\\d*")) {
                    noplayersField.setText(newValue.replaceAll("[^\\d]", ""));
                }
            }
        });
    }
    private void getID(){
        String query = "select id from ptdb4.places order by 1 desc";
        try (Connection con = DataBaseConfig.connect();
             PreparedStatement pst = con.prepareStatement(query)) {
            try (ResultSet rs = pst.executeQuery()) {
                if(rs.next()) {
                    a = rs.getInt("id")+7;
                }
                else
                    a=100;
            }

        } catch (SQLException ex) {
            ex.printStackTrace();
        }
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
    private void showSuccessAlert(String title, String message) {
        Alert alert = new Alert(Alert.AlertType.INFORMATION);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }
}