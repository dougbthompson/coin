
public class PuppyApp {
  public static void main(String[] args) {
    Puppy pup1 = new Puppy();
    Puppy pup2 = new Puppy("Zelda");
    pup1.name = pup2.name;
    System.out.print("Here is pup1: " + pup1.name);
    System.out.println(", and pup2: " + pup2.name);
  }
}

