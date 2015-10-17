

vertices = {'A', 'B', 'C', 'D', 'E', 'F'}
edges = {
            {1, 'A', 'B'},
            {5, 'A', 'C'},
            {3, 'A', 'D'},
            {4, 'B', 'C'},
            {2, 'B', 'D'},
            {1, 'C', 'D'},
            {3, 'C', 'F'},
            {1, 'F', 'E'},
        }



function f(t1, t2)
  return t1[1] < t2[1]
end


table.sort(edges, f)