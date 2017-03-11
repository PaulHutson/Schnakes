<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="Schnakes.Index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
    <head runat="server">
        <title></title>
        <!-- Style items -->
		<style>
			body
			{
				background-color:#b0c4de;
				margin: 0px;
        		padding: 0px;
			}
			
			#container {
		        background-color: #FFF;
		        display: inline-block;
		        width: 300px;
		        height: 300px;
		        border-style:solid;
				border-width:10px;
			}
		</style>
    </head>
    <body>
        <form id="form1" runat="server">
            <div id="container">
                <canvas id="demoCanvas"></canvas>
            </div>
		    <div id="newGameContainer">
			    <input type="button" value="New Game" onclick="deaded=true;NewGame();"/>
		    </div>
        </form>
    </body>    
    
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
	<script src="https://code.createjs.com/createjs-2015.11.26.min.js"></script>
    <script type="text/javascript">
        // Global variables
        var snakeLength = 4;
        var snakeShowing = 1;
        var snakeSpeed = 100;
        var snakeDirection = "R";
        var snakeHeadLocationX = 10;
        var snakeHeadLocationY = 10;
        var snakeLowCount = 1;
        var snakeTotCount = 1;
        var snakeElementSize = 10;
        var snakeFoodLocX = 0;
        var snakeFoodLocY = 0;
        var snakeScore = 0;
        var deaded = false;
        var layer;
        var scoringLayer;
        var stage;
        var scoreText;
        var highScore = 0;
        var highlightText;
        var grid = [];

        // Stop the arrow keys moving the page around
        $(document).keydown(function (e) {
            // Prevent the default thing happening when the key is pressed
            e.preventDefault();

            // Find which code it is.
            var code = (e.keyCode ? e.keyCode : e.which);

            // Check the different code and update the directions
            if (code == "40") {
                // Down...
                snakeDirection = "D";
            } else if (code == "39") {
                // Right
                snakeDirection = "R";
            } else if (code == "38") {
                // Up
                snakeDirection = "U";
            } else if (code == "37") {
                // Left
                snakeDirection = "L";
            }
        });

        // On the start of the page, run this..
        $(document).ready(function () {
            // Create the stage
            stage = new createjs.Stage("demoCanvas");

            // Containera
            containera = new createjs.Container();

            // Now add the scoring layer
            scoringLayer = new createjs.Container();

            // Create some text
            scoreText = new createjs.Text("...", "20px Arial", "green");
            scoreText.x = 5;
            scoreText.y = 20;
            scoreText.textBaseline = "alphabetic";
            scoringLayer.addChild(scoreText);

            // Create some text
            highlightText = new createjs.Text("", "100px Arial", "red");
            highlightText.x = 100;
            highlightText.y = 20;
            highlightText.textBaseline = "alphabetic";
            scoringLayer.addChild(highlightText);

            // add the layer to the stage
            stage.addChild(layer);
            stage.addChild(scoringLayer);

            // Update the stage
            stage.update();
            
            // New Game
            NewGame();
        });

        // Game functions
        // Create a new game
        function NewGame() {
            // Remove any existing blocks 
            if (snakeLowCount != snakeTotCount) {
                for (var i = snakeLowCount; i <= snakeTotCount; i++) {
                    SnakeRemovePiece(i);
                }

                stage.removeChild(snakefood);
                stage.update();
            }

            // Set up everything
            grid = [];
            snakeLength = 5;
            snakeShowing = 1;
            snakeSpeed = 100;
            snakeDirection = "R";
            snakeLowCount = 1;
            snakeScore = 0;
            scoreText.text = "Score : 0";
            deaded = false;
            snakeHeadLocationX = 10;
            snakeHeadLocationY = 10;
            snakeTotCount = 1;
            snakeLowCount = 1;
            snakeSpeed = 100;

            // Reset the death message
            highlightText.text = "";
            stage.update();

            // Add the first block
            //AddBlock();

            // Start the game
            //StartGame();
        }

        // Add a block to the screen
        function AddBlock() {
            // Create the name item
            //var newItemName = "Snake" + snakeTotCount;

            // Create a new group
            var s = CreateSquare("red", snakeHeadLocationX, snakeHeadLocationY);

            // Add the snake item to the grid
            grid["LOC" + snakeHeadLocationX + "," + snakeHeadLocationY] = true;

            // Update the stage
            stage.addChild(s);
            stage.update();
        }

        // Move the snake
        function SnakeMove() {
            // Variables for use in the snake move function
            var newHeadX = snakeHeadLocationX;
            var newHeadY = snakeHeadLocationY;

            // New X and Y position
            if (snakeDirection == "R") {
                newHeadX = snakeHeadLocationX + 10;
            } else if (snakeDirection == "L") {
                newHeadX = snakeHeadLocationX - 10;
            } else if (snakeDirection == "U") {
                newHeadY = snakeHeadLocationY - 10;
            } else {
                newHeadY = snakeHeadLocationY + 10;
            };

            // Set the size to be longer
            snakeShowing++;
            snakeTotCount++;

            // Check whether it is colliding
            SnakeCheckNoCollide(newSnakeElement, newHeadX, newHeadY);

            // Check whether the snake is still alive.
            if (!deaded) {
                // Set the new head location
                snakeHeadLocationX = newHeadX;
                snakeHeadLocationY = newHeadY;

                // Add the first block
                var newSnakeElement = AddBlock();

                // Now set the count down for the piece removal
                if (snakeShowing == snakeLength) {
                    SnakeRemovePiece(snakeLowCount);
                };

                // Let the snake eat
                SnakeEat();

                // Set this to make this work next time.
                setTimeout("SnakeMove();", snakeSpeed);
            };
        }

        // Generate some new snake food
        var containerSF;
        function SnakeFood() {
            // Generate a new X and Y coord
            snakeFoodLocX = (Math.floor(Math.random() * 28) * 10) + 10;
            snakeFoodLocY = (Math.floor(Math.random() * 29) * 10) + 10;

            // Create the square
            var s = CreateSquare("#000", snakeFoodLocX, snakeFoodLocY);
            containerSF = new createjs.Container();
            containerSF.addChild(s);

            // Add the block and draw it as well.
            stage.addChild(containerSF);
            stage.update();
        }

        // Snake Food Location
        function SnakeEat() {
            // Check whether the snake head and the food are in the same place
            if ((snakeHeadLocationX == snakeFoodLocX) && (snakeHeadLocationY == snakeFoodLocY)) {
                // Increase the size of the snake by one
                snakeLength++;

                // Remove the existing snake food
                layer.remove(layer.get(".SnakeFood")[0]);
                layer.draw();

                // Update the score
                snakeScore += 10;

                // Make this faster
                if (snakeSpeed > 10) {
                    snakeSpeed -= 4;
                }

                // Now change the text.
                scoreText.setText("Score : " + snakeScore);
                scoringLayer.draw();

                // Generate a bit more food
                SnakeFood();
            }
        }
        
        // Create a new square shape object
        function CreateSquare(colour, x, y) {
            var s = new createjs.Shape();
            s.outColor = colour;
            s.graphics.beginFill(s.outColor).drawRect(0, 0, width, height).endFill();
            return s;
        }

        
        ////Create a Shape DisplayObject.
        //square = new createjs.Shape();
        //square.graphics.beginFill("red").drawRect(10, 10, 10, 10);
        ////Set position of Shape instance.
        //square.x = square.y = 50;
        ////Add Shape instance to stage display list.
        //stage.addChild(square);
        ////Update stage will render next frame
        //stage.update();
    </script>
</html>
