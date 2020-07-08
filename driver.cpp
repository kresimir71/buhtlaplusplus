

/*C
#+OPTIONS: toc:nil 

For a rare example of mixing C++ and GNU Prolog, have a look at 

[[https://github.com/kresimir71/gprolog_wrapper][~https://github.com/kresimir71/gprolog_wrapper~]]

The program below calls prolog functions and receives calls from prolog.

#+BEGIN_SRC
C*/

#include <string>
#include <gprolog.h>

#include <iostream>
#include <functional>
#include <exception>
#include <vector>
#include <assert.h>

static int
find_atom_id (const char *atomname)
{
  int id = Pl_Find_Atom (const_cast < char *>(atomname));
  if (id == -1)
    {
      std::string msg
      {
      std::string ("no atom found named ") + atomname +
	  ", prolog exception on line " + std::to_string (__LINE__) +
	  " of file " + __FILE__};
      throw std::runtime_error (msg);
    }
  return id;
}

static void
main01 (int argc, char **argv)
{

  Pl_Start_Prolog (argc, argv);
  Pl_Query_Begin (PL_TRUE);
  {

    PlTerm term1 = Pl_Mk_Variable ();

    int functor = find_atom_id ("read");
    int result = Pl_Query_Call (functor, 1, &term1);

    if (result == PL_EXCEPTION)
      {
	PlTerm exception = Pl_Get_Exception ();
	Pl_Write (exception);

	std::string msg
	{
	std::string ("prolog exception on line ") +
	    std::to_string (__LINE__) + " of file " + __FILE__};
	throw std::runtime_error (msg);
      }

    functor = find_atom_id ("simplifyGrammar");
    PlTerm term2[] = { term1, Pl_Mk_Variable () };
    // result = 
    Pl_Query_Call (functor, 2, term2);

    int functor2 = find_atom_id ("write");
    // int result2 =
    Pl_Query_Call (functor2, 1, &term2[1]);

  }

  Pl_Query_End (PL_CUT);
  Pl_Stop_Prolog ();

}

int
main (int argc, char **argv)
{

  main01 (argc, argv);

}

static void
get_list (PlTerm list_or_no_list, std::vector < PlTerm > &vec)
{

  // -1 when not a list
  int InputLength = Pl_List_Length (list_or_no_list);

  if (InputLength > 0)
    {
      vec.resize (InputLength);
      int size01 = Pl_Rd_Proper_List_Check (list_or_no_list, vec.data ());
      assert (size01 == InputLength);
      assert (Type_Of_Term (list_or_no_list) == PL_LST);
      return;
    }
  else if (InputLength == 0)
    {
      vec.clear ();
      assert (Type_Of_Term (list_or_no_list) == PL_ATM);
      return;
    }

  vec.clear ();
  assert (-1 == InputLength);
  assert (Type_Of_Term (list_or_no_list) == PL_PLV);
  return;
}

static PlTerm
get_list (const std::vector < PlTerm > &vec)
{
  if (vec.size () == 0)
    {
      PlTerm ret = Pl_Mk_Proper_List (vec.size (), vec.data ());
      int Type = Type_Of_Term (ret);
      assert (Type != PL_LST);
      assert (Type == PL_ATM);
      return ret;

    }
  else
    {
      PlTerm ret = Pl_Mk_Proper_List (vec.size (), vec.data ());
      int Type = Type_Of_Term (ret);
      assert (Type == PL_LST);
      assert (Type != PL_ATM);
      return ret;
    }
}

/*C
#+END_SRC

Below is a 'map' facility to apply a given function to a given list in
an element by element fashion. Here with three outputs and the
possibility to supplement input during the call. As for C++ below,
it's not super optimal, but okay. I have also no doubt that
[[./buhtla.pl][buhtla.pl]] is very well written. As for
interoperability of Prolog and C++, keep in mind that this is the
version 0.0.1 of the author's understanding of the matter.

#+BEGIN_SRC
C*/

extern "C" PlBool
mapStacks (PlTerm func, PlTerm input, PlTerm context, PlTerm output1,
	   PlTerm output2, PlTerm output3)
{
  assert (Type_Of_Term (func) == PL_ATM);
  assert (Type_Of_Term (input) == PL_LST || Type_Of_Term (input) == PL_ATM);
  assert (Type_Of_Term (output1) == PL_PLV);
  assert (Type_Of_Term (output2) == PL_PLV);
  assert (Type_Of_Term (output3) == PL_PLV);

  int Func;
  Func = Pl_Rd_Atom_Check (func);
  if (Func == -1)
    {
      std::string msg
      {
      std::string ("no atom found ") + ", prolog exception on line " +
	  std::to_string (__LINE__) + " of file " + __FILE__};
      throw std::runtime_error (msg);
    }

  PlTerm Current;
  std::vector < PlTerm > Input;
  std::vector < PlTerm > Output2;
  std::vector < PlTerm > Output3;
  std::vector < PlTerm > Output1;

  get_list (input, Input);

  while (Input.size () > 0)
    {

      Pl_Query_Begin (PL_TRUE);

      Current = *Input.begin ();
      Input.erase (Input.begin (), Input.begin () + 1);

      PlTerm Result1 = Pl_Mk_Variable (), PrependToInput =
	Pl_Mk_Variable (), Result2 = Pl_Mk_Variable (), Result3 =
	Pl_Mk_Variable ();
      PlTerm args8[]
      {
      Current, context, Result1, PrependToInput, Result2, Result3,
	  get_list (Input), get_list (Output1)};
      /*C
         #+END_SRC
         The call can also use the rest input and
         current output (only the first of the three outputs).
         #+BEGIN_SRC
         C*/
      int result = Pl_Query_Call (Func, 8, args8);
      if (result == PL_EXCEPTION)
	{
	  PlTerm exception = Pl_Get_Exception ();
	  Pl_Write (exception);

	  std::string msg
	  {
	  std::string ("prolog exception on line ") +
	      std::to_string (__LINE__) + " of file " + __FILE__};
	  throw std::runtime_error (msg);
	}
      if (result != PL_TRUE)
	{

	  std::string msg
	  {
	  std::string ("prolog failed on line ") +
	      std::to_string (__LINE__) + " of file " + __FILE__};
	  throw std::runtime_error (msg);
	}

      std::vector < PlTerm > Result1Vector;
      get_list (Result1, Result1Vector);
      Output1.insert (Output1.end (), Result1Vector.begin (),
		      Result1Vector.end ());

      std::vector < PlTerm > PrependToInputVector;
      get_list (PrependToInput, PrependToInputVector);
      Input.insert (Input.begin (), PrependToInputVector.begin (),
		    PrependToInputVector.end ());

      std::vector < PlTerm > Result2Vector;
      get_list (Result2, Result2Vector);
      Output2.insert (Output2.end (), Result2Vector.begin (),
		      Result2Vector.end ());

      std::vector < PlTerm > Result3Vector;
      get_list (Result3, Result3Vector);
      Output3.insert (Output3.end (), Result3Vector.begin (),
		      Result3Vector.end ());

      Pl_Query_End (PL_CUT);
    }

  Un_Proper_List_Check (Output1.size (), Output1.data (), output1);
  Un_Proper_List_Check (Output2.size (), Output2.data (), output2);
  Un_Proper_List_Check (Output3.size (), Output3.data (), output3);

  return PL_TRUE;

}

/*C
#+END_SRC
C*/
