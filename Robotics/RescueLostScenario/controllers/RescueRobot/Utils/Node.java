package Utils;

/**
 * Nodo della grid map
 */
public class Node {
    public boolean walkable;      //TRUE = FREE , FALSE = OBSTACLE
    public int x;
    public int y;

    // Valori delle coordinate reali
    public double realX;
    public double realZ;

    // Variabili per memorizzare g(n) e h(n) e il nodo genitore per ricostruire il percorso
    public double gCost;
    public double hCost;
    public Node parent;

    public Node(int x, int y, double realX, double realZ, boolean walkable) {
        this.walkable = walkable;
        this.x = x;
        this.y = y;

        this.realX = realX;
        this.realZ = realZ;
    }

    public double getFCost() {
        return gCost + hCost;
    }

    public String toString() {
        return " (" + x +", " + y + ", " + walkable + " )" ;
    }
}
