package com.example.pawntodb4app;

public class Player {
    private final int id;
    private final String firstName;
    private final String lastName;
    private final String groupId;
    private final String maxElo;

    public Player(int id, String firstName, String lastName, String groupId, String maxElo) {
        this.id = id;
        this.firstName = firstName;
        this.lastName = lastName;
        this.groupId = groupId;
        this.maxElo = maxElo;
    }

    public int getId() {
        return id;
    }

    public String getFirstName() {
        return firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public String getGroupId() {
        return groupId;
    }

    public String getMaxElo() {
        return maxElo;
    }

    @Override
    public String toString() {
        return "Player{" +
                "id=" + id +
                ", firstName='" + firstName + '\'' +
                ", lastName='" + lastName + '\'' +
                ", groupId=" + groupId +
                '}';
    }
}
