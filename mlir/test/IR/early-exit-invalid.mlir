
// RUN: mlir-opt %s --split-input-file --verify-diagnostics


// expected-error @+1 {{operation has a nested predecessor but does not have the HasBreakingControlFlowOpInterface trait}}
  func.func @loop_continue() {
   scf.loop {
// expected-note @+1 {{for this predecessor operation (scf.continue)}}
     scf.continue 2
   } loc("loop1")
   return
}

// -----

func.func @loop_result_mismatch(%value : f32) {
 // expected-error @+1 {{'scf.loop' op along control flow edge from Operation scf.break to parent: successor operand type #0 'f32' should match successor input type #0 'i32'}}
 %result = scf.loop -> i32 {
   scf.break 1 %value : f32 // expected-note {{region branch point}}
 }
 return
}

// -----

func.func @loop_result_number_mismatch(%value : f32) {
 // expected-error @+1 {{'scf.loop' op along control flow edge from Operation scf.break to parent: region branch point has 1 operands, but region successor needs 2 inputs}}
 %result:2 = scf.loop -> f32, f32 {
   scf.break 1 %value : f32 // expected-note {{region branch point}}
 }
 return
}

// -----

func.func @loop_continue_mismatch(%init : i32, %value : f32) {
 // expected-error @+1 {{'scf.loop' op along control flow edge from Operation scf.continue to Region #0: successor operand type #0 'f32' should match successor input type #0 'i32'}}
 scf.loop iter_args(%next = %init) : i32 {
   scf.continue 1 %value : f32 // expected-note {{region branch point}}
 }
 return
}


// -----

func.func @loop_iterargs_mismatch(%init : i32, %value : f32) {
 // expected-error @+2 {{'scf.loop' op along control flow edge from parent to Region #0: successor operand type #0 'i32' should match successor input type #0 'f32'}}
 // expected-note @+1 {{region branch point}}
 "scf.loop"(%init) ({
    ^body(%next : f32):
   scf.continue 1 %init : i32
 })  : (i32) -> ()
 return
}

// -----

func.func @loop_iterargs_mismatch(%init : i32, %value : f32) {
 // expected-error @+2 {{'scf.loop' op along control flow edge from parent to Region #0: region branch point has 1 operands, but region successor needs 2 inputs}}
 // expected-note @+1 {{region branch point}}
 "scf.loop"(%init) ({
    ^body(%next : i32, %next2 : f32):
   scf.continue 1 %init : i32
 })  : (i32) -> ()
 return
}

// -----

// scf.for lacks PropagateControlFlowBreak, so it cannot be an intermediate
// parent for scf.break N with N > 1.
func.func @break_through_for_missing_trait(%lb: index, %ub: index, %step: index, %cond: i1) {
  scf.loop {
    scf.for %i = %lb to %ub step %step {
      scf.if %cond {
        // expected-error @+1 {{breaking control regions through an op that does not have the PropagateControlFlowBreak trait}}
        scf.break 3
      }
    }
  }
  return
}

// -----

// Break exceeding nesting depth — walks up through scf.if, scf.loop, func.func
// and func.func lacks PropagateControlFlowBreak.
func.func @break_exceeds_nesting(%cond: i1) {
  scf.loop {
    scf.if %cond {
      // expected-error @+1 {{breaking control regions through an op that does not have the PropagateControlFlowBreak trait}}
      scf.break 5
    }
  }
  return
}

// -----

// scf.while lacks PropagateControlFlowBreak, so break through it is rejected.
// The scf.while verifier catches this first as the after region must terminate
// with scf.yield.
func.func @break_through_while(%cond: i1) {
  %init = arith.constant true
  scf.loop {
    // expected-error @+1 {{'scf.while' op expects the 'after' region to terminate with 'scf.yield'}}
    scf.while(%arg = %init) : (i1) -> i1 {
      scf.condition(%arg) %arg : i1
    } do {
    ^bb0(%arg2: i1):
      // expected-note @+1 {{terminator here}}
      scf.break 3
    }
  }
  return
}
