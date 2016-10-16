#!/bin/bash

FST_DIR="fsts"
PDF_DIR="pdfs"
SYMBOLS="syms.txt"
TEST_DIR="test"
OUTPUT="results"

function clear_files {
    rm -rf $FST_DIR $PDF_DIR $OUTPUT $TEST_DIR transdutorFinal.fst
}

function create_step {
    echo "Compiling $1..."
    fstcompile --isymbols=$SYMBOLS --osymbols=$SYMBOLS $1.txt | fstarcsort > $FST_DIR/$1.fst
    fstdraw --portrait --isymbols=$SYMBOLS --osymbols=$SYMBOLS $FST_DIR/$1.fst | dot -Tpdf  > $PDF_DIR/$1.pdf
}

function run_tests {
    echo "Running tests..."
    for i in godinho ferreira
    do
        # ./word2fst.py $i > $TEST_DIR/w-$i.txt
        fstcompile --isymbols=$SYMBOLS --osymbols=$SYMBOLS w-$i.txt | fstarcsort > $FST_DIR/w-$i.fst
        run_step "step1-4" $i
    done
}

function run_step {
    echo "Running $1 with $2..."
    fstcompose $FST_DIR/w-$2.fst $FST_DIR/$1.fst | fstshortestpath | fstarcsort | fstproject --project_output | fstrmepsilon | fstdraw --portrait --isymbols=$SYMBOLS --osymbols=$SYMBOLS | dot -Tpdf > $OUTPUT/$1-$2.pdf
    fstcompose $FST_DIR/w-$2.fst $FST_DIR/$1.fst | fstshortestpath | fstarcsort | fstproject --project_output | fstrmepsilon | fstprint --acceptor --isymbols=$SYMBOLS > $OUTPUT/$2.txt
}

function compile_final {
    echo "Compiling final FST..."
    fstcompose $FST_DIR/step1.fst $FST_DIR/step2.fst | fstarcsort > $FST_DIR/step1-2.fst
    fstcompose $FST_DIR/step1-2.fst $FST_DIR/step3.fst | fstarcsort > $FST_DIR/step1-3.fst
    fstcompose $FST_DIR/step1-3.fst $FST_DIR/step4.fst | fstarcsort > $FST_DIR/step1-4.fst
    fstdraw --portrait --isymbols=$SYMBOLS --osymbols=$SYMBOLS $FST_DIR/step1-4.fst | dot -Tpdf  > $PDF_DIR/step1-4.pdf
    cp $FST_DIR/step1-4.fst ./transdutorFinal.fst
}

clear_files
mkdir $PDF_DIR $TEST_DIR $FST_DIR $OUTPUT
create_step step1
create_step step2
create_step step3
create_step step4
compile_final
run_tests
