with Base_Types;
use type Base_Types.Row_Count_T;
use type Base_Types.Column_Count_T;
package Board_Pkg with
   Spark_Mode
is

   type Board_T is tagged private;
   type Cell_T is (Alive, Dead) with
      Size => 1;

   Empty_Board : constant Board_T;

   -- accessor functions
   function Rows
     (Board : Board_T)
     return Base_Types.Row_Count_T;
   function Columns
     (Board : Board_T)
     return Base_Types.Column_Count_T;

   function Get_State
     (Board  : in Board_T;
      Row    : in Base_Types.Row_Count_T;
      Column : in Base_Types.Column_Count_T)
     return Cell_T;

   -- set state of cell at row/column postcondition: 'get_state' at row/column
   -- should return input state
   procedure Set_State
     (Board  : in out Board_T;
      Row    : in     Base_Types.Row_T;
      Column : in     Base_Types.Column_T;
      State  : in     Cell_T) with
      Post => Get_State (Board, Row, Column) = State and
      (if Column > Columns (Board'Old) then Column = Columns (Board)) and
      (if Row > Rows (Board'Old) then Row = Rows (Board));

      -- return True if every used cell in the two boards match (i.e, used
      -- rows/columns must match, and only compare cells up to the used
      -- row/column)
   function "="
     (Left, Right : Board_T)
     return Boolean;

   -- reset board
   procedure Clear (Board : out Board_T) with
      Post => Board.Rows = 0 and then Board.Columns = 0;

private

   -- each row is just an array of bits
   type Unconstrained_Row_T is array (Base_Types.Column_T range <>) of Cell_T;
   pragma PACK (Unconstrained_Row_T);
   subtype Actual_Row_T is Unconstrained_Row_T (1 .. Base_Types.Column_T'Last);
   -- board layout is an array of rows
   type Matrix_T is array (Base_Types.Row_T) of Actual_Row_T;
   -- board consists of layout and count of rows and columns (we keep track of
   -- used rows and columns so the display can be limited to necessary cells)
   type Board_T is tagged record
      Matrix         : Matrix_T := (others => (others => Dead));
      Actual_Rows    : Base_Types.Row_Count_T    := 0;
      Actual_Columns : Base_Types.Column_Count_T := 0;
   end record;

   function Rows
     (Board : Board_T)
     return Base_Types.Row_Count_T is (Board.Actual_Rows);
   function Columns
     (Board : Board_T)
     return Base_Types.Column_Count_T is (Board.Actual_Columns);

   function "="
     (Left, Right : Board_T)
     return Boolean is
     (if Left.Rows /= Right.Rows then False
      elsif Left.Columns /= Right.Columns then False
      elsif Left.Rows = 0 and Right.Rows = 0 then True
      else
        (for all R in 1 .. Left.Rows =>
           (for all C in 1 .. Left.Columns =>
              Left.Matrix (R) (C) = Right.Matrix (R) (C))));

   function Get_State
     (Board  : in Board_T;
      Row    : in Base_Types.Row_Count_T;
      Column : in Base_Types.Column_Count_T)
      return Cell_T is (if row in base_types.row_t and column in base_types.column_t then Board.Matrix (Row) (Column)
                       else dead);

   Empty_Board : constant Board_T :=
     (Matrix         => (others => (others => Dead)), Actual_Rows => 0,
      Actual_Columns => 0);

end Board_Pkg;
