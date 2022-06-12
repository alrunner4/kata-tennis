module Tennis
import Data.Fin

%default total

public export
data Player = L | R

public export
Show Player where
   show L = "player 1"
   show R = "player 2"

public export
Eq Player where
   L == L = True
   R == R = True
   _ == _ = False

mutual
   public export
   PlayingState: Type
   PlayingState = GameState {winner = Nothing}
   public export
   WinnerState: Player -> Type
   WinnerState p = GameState {winner = Just p}
   public export
   data GameState: {winner: Maybe Player} -> Type where
      Scores: Fin 4 -> Fin 4 -> PlayingState
      Advantage:     Player  -> PlayingState
      Winner:    (p: Player) -> WinnerState p

public export
deuceState: PlayingState
deuceState = Scores 3 3

public export total
isDeuce: PlayingState -> Bool
isDeuce( Scores FZ FZ ) = True
isDeuce _ = False

public export total
score: Fin 4 -> String
score 3 = "love"
score 2 = "fifteen"
score 1 = "thirty"
score 0 = "forty"

export total
newGameState: PlayingState
newGameState = Scores last last

public export total
gameScore: {winner: Maybe Player} -> GameState {winner} -> String
gameScore s@(Scores l r) = if isDeuce s then "deuce"
   else score l ++ if l == r then " all" else ", " ++ score r
gameScore (Advantage p) = "advantage " ++ show p
gameScore (Winner p) = "winner " ++ show p

public export
AnyState: Type
AnyState = (winner ** GameState {winner})

public export total
Point: Type
Point = PlayingState -> AnyState

public export total
point: Player -> Point
point p (Advantage q) = if p == q then (_ ** Winner p) else (_ ** deuceState)
point p (Scores FZ FZ) = (_ ** Advantage p)
point L (Scores FZ _) = (_ ** Winner L) -- these pattern matches are the reason why `score` counts
point R (Scores _ FZ) = (_ ** Winner R) -- down instead of up
point L (Scores (FS l) r) = (_ ** Scores (weaken l) r)
point R (Scores l (FS r)) = (_ ** Scores l (weaken r))

public export
evalGame: Point -> PlayingState -> AnyState
evalGame = ($)

public export
winner: Point -> PlayingState -> Player

public export
winnerL: GameState {winner = Just L}

--public export total
--totalGame: (points: List Point) -> ( foldr ($) (Scores 0 0) points = Winner _ )
