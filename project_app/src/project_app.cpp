#include "project_app.h"
#include "module_a.h"
#include <iostream>
project_app::project_app() {}

int main(int argc, char** argv)
{
    std::cout << "Project App started" << std::endl;
    a_space::module_a moduleA;
    moduleA.hey();
    return 0;
}
