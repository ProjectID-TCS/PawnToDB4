package com.example.pawntodb4app;

public class Match {
    String id;
    String gameRecordId;
    String tournamentId;
    String result;
    String date;

    public Match(String id, String gameRecordId, String tournamentId, String result, String date) {
        this.id = id;
        this.gameRecordId = gameRecordId;
        this.tournamentId = tournamentId;
        this.result = result;
        this.date = date;
    }
}
