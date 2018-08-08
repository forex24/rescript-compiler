(* Copyright (C) 2015-2016 Bloomberg Finance L.P.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * In addition to the permissions granted to you by the LGPL, you may combine
 * or link a "work that uses the Library" with a publicly distributed version
 * of this file to produce a combined library or application, then distribute
 * that combined work under the terms of your choosing, with no requirement
 * to comply with the obligations normally placed on you by section 4 of the
 * LGPL version 3 (or the corresponding section of a later version of the LGPL
 * should you choose to use a later version).
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. *)


open Ast_helper 

let exp_apply_no_label ?loc ?attrs a b = 
  Exp.apply ?loc ?attrs a (Ext_list.map (fun x -> "", x) b)

(* let fun_no_label ?loc ?attrs  pat body = 
  Ast_compatible.fun_ ?loc ?attrs  pat body *)

let arrow_no_label ?loc ?attrs b c = 
  Typ.arrow ?loc ?attrs "" b c 

let discard_exp_as_unit loc e = 
  exp_apply_no_label ~loc     
    (Exp.ident ~loc {txt = Ast_literal.Lid.ignore_id; loc})
    [Exp.constraint_ ~loc e 
       (Ast_literal.type_unit ~loc ())]


let tuple_type_pair ?loc kind arity = 
  let prefix  = "a" in
  if arity = 0 then 
    let ty = Typ.var ?loc ( prefix ^ "0") in 
    match kind with 
    | `Run -> ty,  [], ty 
    | `Make -> 
      (Typ.arrow "" ?loc
         (Ast_literal.type_unit ?loc ())
         ty ,
       [], ty)
  else
    let number = arity + 1 in
    let tys = Ext_list.init number (fun i -> 
        Typ.var ?loc (prefix ^ string_of_int (number - i - 1))
      )  in
    match tys with 
    | result :: rest -> 
      Ext_list.reduce_from_left (fun r arg -> Typ.arrow "" ?loc arg r) tys, 
      List.rev rest , result
    | [] -> assert false
    
    

let js_obj_type_id  = 
  Ast_literal.Lid.js_obj 

let re_id  = 
  Ast_literal.Lid.js_re_id 

let to_js_type loc  x  = 
  Typ.constr ~loc {txt = js_obj_type_id; loc} [x]

let to_js_re_type loc  =
  Typ.constr ~loc { txt = re_id ; loc} []
    
let to_undefined_type loc x =
  Typ.constr ~loc
    {txt = Ast_literal.Lid.js_undefined ; loc}
    [x]  

let single_non_rec_value  name exp = 
  Str.value Nonrecursive 
    [Vb.mk (Pat.var name) exp]

let single_non_rec_val name ty = 
  Sig.value 
    (Val.mk name ty)