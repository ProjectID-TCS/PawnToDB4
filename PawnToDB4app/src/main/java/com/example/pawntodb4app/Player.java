package com.example.pawntodb4app;

public class Player {
    private final int id;
    private final String firstName;
    private final String lastName;
    private final int groupId;

    public Player(int id, String firstName, String lastName, int groupId) {
        this.id = id;
        this.firstName = firstName;
        this.lastName = lastName;
        this.groupId = groupId;
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

    public int getGroupId() {
        return groupId;
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
