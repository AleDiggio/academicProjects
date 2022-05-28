package Utils;

import java.util.*;
/**
 * Classe per gestire la grid map di nodi per trovare il percorso
 */
public class Grid {
    public Node[][] nodes;
    int gridWidth, gridHeight;
    public Cell[][] realMap;

    public Grid(int width, int height, Cell[][] realMap) {
        gridWidth = width;
        gridHeight = height;
        nodes = new Node[width][height];
        this.realMap = realMap;

        // GRID PER IL PATH FINDING BUILDING
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                nodes[x][y] = new Node(x, y, realMap[x][y].x, realMap[x][y].y, realMap[x][y].getStatus());
            }
        }
    }

    public void updateGrid(Cell [][] realMap) {
        
        this.realMap = realMap;

        // GRID PER IL PATH FINDING BUILDING
        for (int x = 0; x < gridWidth; x++) {
            for (int y = 0; y <  gridHeight; y++) {
                nodes[x][y] = new Node(x, y, realMap[x][y].x, realMap[x][y].y, realMap[x][y].getStatus());
            }
        } 
    }

    //Metodo per restituire i 4 vicini di un nodo 
    public List<Node> get4Neighbours(Node node) {
        List<Node> neighbours = new ArrayList<Node>();

        // N
        if (node.y + 1 >= 0 && node.y + 1  < gridHeight) {
            neighbours.add(nodes[node.x][node.y + 1]);
        }

        // S
        if (node.y - 1 >= 0 && node.y - 1  < gridHeight) {
            neighbours.add(nodes[node.x][node.y - 1]);
        }

        // E
        if (node.x + 1 >= 0 && node.x + 1  < gridHeight) {
            neighbours.add(nodes[node.x + 1][node.y]);
        }

        // W
        if (node.x - 1 >= 0 && node.x - 1  < gridHeight) {
            neighbours.add(nodes[node.x - 1][node.y]);
        }

        return neighbours;
    }

    // Metodo per convertire double[] che rappresenta una cella in un Nodo
    public Node DoubleToNode(double[] cell) {

        for(int x = 0; x < gridWidth; x++) {
            for(int y = 0; y < gridHeight; y++) {
                if(nodes[x][y].realX == cell[0] && nodes[x][y].realZ == cell[1]) {
                    return nodes[x][y];
                }
            }
        }

        System.out.println("Errore individuazione cella");
        return new Node(0,0,0,0,false);
        
    }

    // Metodo per stampare la mappa
    public void printMap() {
        System.out.println("");
        for (int x = 0; x < gridWidth; x++) {
            for (int y = 0; y < gridHeight; y++) {
                System.out.print(nodes[x][y]);
            }
            System.out.println("\n");
        }
    }
}
