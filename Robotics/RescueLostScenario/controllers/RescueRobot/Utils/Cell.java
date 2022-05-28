package Utils;

/**
 * Classe per gestira una cella della mappa 
 */
public class Cell {

    public double x;
    public double y;
    public char status;      //O = OSTACOLO, F = FREE, S = STATO SCONOSCIUTO, R = ROBOT DISPERSO
    public boolean visited; 

    public Cell(double x, double y, char status, boolean visited) {
        this.x = x;
        this.y = y;
        this.status = status; 
        this.visited = visited;
    }

    public Cell(double x, double y, char status) {
        this.x = x;
        this.y = y;
        this.status = status;
    }

    public Cell(double x, double y, boolean walkable) {
        this.x = x;
        this.y = y;
        if(walkable == true) {
            this.status = 'F';
        } else {
            this.status = 'O';
        }
    }

    public boolean getStatus() {
        if(this.status == 'O' || this.status == 'S') {
            return false;
        } else {
            return true;
        }
    }

    public void setStatus(char status) {
        this.status = status;
    }

    public String toString() {
        return " {" + x +", " + y +'}';
    }
}
