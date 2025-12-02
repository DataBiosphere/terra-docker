module.exports = {
    'env': {
        'browser': true,
        'es6': true,
    },
    'extends': [
        'google',
    ],
    'globals': {
        'Atomics': 'readonly',
        'SharedArrayBuffer': 'readonly',
    },
    'parserOptions': {
        'ecmaVersion': 2018,
        'sourceType': 'module',
    },
    'rules': {
        'comma-dangle': ['error', 'never'],
        //80 is the standard, but this required the least refactoring.
        'max-len': ['error', { 'code': 150 }],
        //TODO: remove the following rules and fix the offenses
        'require-jsdoc': ['error', {
            'require': {
                'FunctionDeclaration': false,
                'MethodDefinition': false,
                'ClassDeclaration': false,
                'ArrowFunctionExpression': false,
                'FunctionExpression': false
            }
        }]
    },
};