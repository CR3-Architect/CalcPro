import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:calcpro_studio/domain/parser/lexer.dart';
import 'package:calcpro_studio/domain/parser/parser.dart';
import 'package:calcpro_studio/domain/ast/ast_node.dart';
import 'package:calcpro_studio/domain/evaluator/ast_evaluator.dart';
import 'package:calcpro_studio/domain/functions/calculus_functions.dart';
import 'package:calcpro_studio/domain/functions/programmer_functions.dart';
import 'package:calcpro_studio/core/enums/angle_mode.dart';

void main() {
  group('Lexer', () {
    test('tokenizes numbers and operators', () {
      final tokens = Lexer('12+34').tokenize();
      expect(tokens[0].type, TokenType.number);
      expect(tokens[0].value, '12');
      expect(tokens[1].type, TokenType.plus);
      expect(tokens[2].type, TokenType.number);
      expect(tokens[3].type, TokenType.eof);
    });

    test('tokenizes identifiers and functions', () {
      final tokens = Lexer('sin(x)').tokenize();
      expect(tokens[0].type, TokenType.identifier);
      expect(tokens[0].value, 'sin');
      expect(tokens[1].type, TokenType.leftParen);
      expect(tokens[2].type, TokenType.identifier);
      expect(tokens[3].type, TokenType.rightParen);
    });

    test('tokenizes nPr and nCr', () {
      expect(Lexer('nPr').tokenize()[0].type, TokenType.nPr);
      expect(Lexer('nCr').tokenize()[0].type, TokenType.nCr);
    });

    test('handles scientific notation', () {
      final tokens = Lexer('1e10').tokenize();
      expect(tokens[0].type, TokenType.number);
      expect(tokens[0].value, '1e10');
    });
  });

  group('Parser', () {
    test('parses simple addition', () {
      final ast = parseExpression('2+3');
      expect(ast, isA<BinOpNode>());
    });

    test('parses function call', () {
      final ast = parseExpression('sin(90)');
      expect(ast, isA<FuncNode>());
    });

    test('parses nPr as binary operator', () {
      final ast = parseExpression('5nPr2');
      expect(ast, isA<BinOpNode>());
    });

    test('parses nCr as binary operator', () {
      final ast = parseExpression('5nCr2');
      expect(ast, isA<BinOpNode>());
    });

    test('throws on invalid expression', () {
      expect(() => parseExpression('2+'), throwsA(isA<ParseException>()));
    });
  });

  group('ASTEvaluator', () {
    double eval(String expr, {AngleMode angleMode = AngleMode.degree}) {
      final ast = parseExpression(expr);
      return ASTEvaluator(angleMode: angleMode).evaluate(ast);
    }

    test('evaluates basic arithmetic', () {
      expect(eval('2+3'), 5);
      expect(eval('10-4'), 6);
      expect(eval('3*4'), 12);
      expect(eval('15/5'), 3);
    });

    test('evaluates power', () {
      expect(eval('2^10'), 1024);
    });

    test('evaluates sqrt', () {
      expect(eval('sqrt(16)'), 4);
    });

    test('evaluates factorial', () {
      expect(eval('5!'), 120);
    });

    test('evaluates nPr', () {
      expect(eval('5nPr2'), 20);
      expect(eval('nPr(5,2)'), 20);
    });

    test('evaluates nCr', () {
      expect(eval('5nCr2'), 10);
      expect(eval('ncr(5,2)'), 10);
    });

    test('evaluates trig in degree mode', () {
      expect(eval('sin(90)', angleMode: AngleMode.degree), closeTo(1, 1e-9));
      expect(eval('cos(0)', angleMode: AngleMode.degree), closeTo(1, 1e-9));
    });

    test('evaluates log and ln', () {
      expect(eval('log(100)'), 2);
      expect(eval('ln(1)'), 0);
    });

    test('throws on division by zero', () {
      expect(() => eval('1/0'), throwsA(isA<EvaluationException>()));
    });

    test('evaluates with variables', () {
      final ast = parseExpression('x*2');
      final result = ASTEvaluator(variables: {'x': 21.0}).evaluate(ast);
      expect(result, 42);
    });

    test('evaluates derivative', () {
      final result = eval('derivative(x^2, x, 3)');
      expect(result, closeTo(6, 1e-4));
    });

    test('evaluates integrate', () {
      final result = eval('integrate(x, x, 0, 1)');
      expect(result, closeTo(0.5, 1e-6));
    });

    test('evaluates sum', () {
      final result = eval('sum(k, k, 1, 10)');
      expect(result, closeTo(55, 1e-9));
    });
  });

  group('CalculusFunctions', () {
    test('derivative of x^2', () {
      final d = CalculusFunctions.derivative((x) => x * x, 3);
      expect(d, closeTo(6, 1e-4));
    });

    test('integrate x from 0 to 1', () {
      final i = CalculusFunctions.integrate((x) => x, 0, 1);
      expect(i, closeTo(0.5, 1e-6));
    });

    test('limit of sin(x)/x as x->0', () {
      final l = CalculusFunctions.limit(
        (x) => x.abs() < 1e-12 ? 1.0 : math.sin(x) / x,
        0,
      );
      expect(l, closeTo(1, 1e-6));
    });

    test('summation', () {
      final s = CalculusFunctions.summation((k) => k.toDouble(), 1, 100);
      expect(s, 5050);
    });
  });

  group('ProgrammerFunctions', () {
    test('bitwise AND', () {
      expect(ProgrammerFunctions.bitwiseAnd(12, 10), 8);
    });

    test('bitwise OR', () {
      expect(ProgrammerFunctions.bitwiseOr(12, 10), 14);
    });

    test('bitwise XOR', () {
      expect(ProgrammerFunctions.bitwiseXor(12, 10), 6);
    });

    test('bitwise NOT', () {
      expect(ProgrammerFunctions.bitwiseNot(0), -1);
    });

    test('shift left', () {
      expect(ProgrammerFunctions.shiftLeft(1, 4), 16);
    });

    test('popcount', () {
      expect(ProgrammerFunctions.popcount(255), 8);
      expect(ProgrammerFunctions.popcount(0), 0);
    });

    test('clz', () {
      expect(ProgrammerFunctions.clz(1), 31);
    });

    test('ones complement', () {
      expect(ProgrammerFunctions.onesComplement(10, bits: 8), 245);
    });

    test('twos complement', () {
      expect(ProgrammerFunctions.twosComplement(1, bits: 8), 255);
    });
  });
}
