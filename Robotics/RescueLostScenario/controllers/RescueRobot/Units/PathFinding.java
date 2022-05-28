package Units;

import Utils.*;

import java.util.*;

public class PathFinding {
    /**
     * Metodo per trovare la lista di Nodi da start a target e convertirla nel formato per fare lo spostamento
     */
    public static List<double[]> findPath(Grid grid, Node startPos, Node targetPos) {
        // Find path
        List<Node> pathInNodes = findPathNodes(grid, startPos, targetPos);

        // Converto la lista in punti double[]
        List<double[]> pathInPoints = new ArrayList<double[]>();

        if (pathInNodes != null)
            for (Node node : pathInNodes)
                pathInPoints.add(new double[]{ node.realX, node.realZ });

        return pathInPoints;
    }

    /**
     * Metodo che implementa A*, ricerca best-first che espande sempre il nodo con fCost = gCost + hCost minore
     */
    private static List<Node> findPathNodes(Grid grid, Node startNode, Node targetNode) {
        
        //Insieme aperto, nodi espansi ma non visitati
        List<Node> openSet = new ArrayList<Node>();

        //Insieme chiuso, nodi esplorati
        HashSet<Node> closedSet = new HashSet<Node>();

        openSet.add(startNode);

        while (openSet.size() > 0) {
            Node currentNode = openSet.get(0);

            // Prendo il nodo a funzione di costo f(N) minore
            for (int k = 1; k < openSet.size(); k++) {

                Node open = openSet.get(k);

                if (open.getFCost() < currentNode.getFCost() || 
                    open.getFCost() == currentNode.getFCost() && open.hCost < currentNode.hCost) {
                    currentNode = open;
                }
            }

            openSet.remove(currentNode);
            closedSet.add(currentNode);

            // Se il nodo corrente = quello di destinazione la ricerca finita
            if (currentNode == targetNode) {
                return retracePath(startNode, targetNode); 
            }

            List<Node> neighbours;
            neighbours = grid.get4Neighbours(currentNode);

            // Per ogni nodo neighbour
            for (Node neighbour : neighbours) {

                // Se un ostacolo o visitato skip
                if (!neighbour.walkable || closedSet.contains(neighbour)) {
                    continue;
                }

                double new_gCost = currentNode.gCost + getDistance(currentNode, neighbour);

                if (new_gCost < neighbour.gCost || !openSet.contains(neighbour) ) {

                    // COSTO PER ANDARE DA START AL NODO G(N)
                    neighbour.gCost = new_gCost; 
                    
                    // EURISTICA H(N)                          
                    neighbour.hCost = getDistance(neighbour, targetNode); 

                    neighbour.parent = currentNode;   //Aggiungo il nodo parent per poter in seguito ricostruire il percorso 
                    
                    // Aggiungi ai nodi da espandere
                    if (!openSet.contains(neighbour)) {
                        openSet.add(neighbour);
                    }

                }
            }
        }

        return null;
    }

    // Metodo per ricostruire il percorso 
    private static List<Node> retracePath(Node startNode, Node endNode) {
        List<Node> path = new ArrayList<Node>();
        Node currentNode = endNode;

        while (currentNode != startNode) {
            path.add(currentNode);
            currentNode = currentNode.parent;
        }

        Collections.reverse(path);
        return path;
    }

    //EURISTICA H(N), AMMISIBILE DATO CHE NON SOVRASTIMA MAI IL COSTO QUINDI A* DA SOLUZIONE OTTIMA
    private static double getDistance(Node nodeA, Node nodeB) {

        return Math.sqrt( Math.pow((nodeB.x - nodeA.x), 2 ) + Math.pow((nodeB.y - nodeA.y),2) ) ;
    }
}

