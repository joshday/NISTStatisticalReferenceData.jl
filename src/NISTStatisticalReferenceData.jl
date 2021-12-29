module NISTStatisticalReferenceData

using Downloads

function parse_dat(file::String)
    lines = filter(!isempty, readlines(file))

    name = split(filter(startswith("Dataset Name:"), lines)[1])[3]

    format_row = findfirst(startswith("File Format:"), lines)
    format = split(lines[format_row])[3]

    certified_values = split(lines[format_row + 1])[[4,6]]
    certified_values_from = parse(Int, certified_values[1])
    certified_values_to = parse(Int, replace(certified_values[2], ")" => ""))
end



end
