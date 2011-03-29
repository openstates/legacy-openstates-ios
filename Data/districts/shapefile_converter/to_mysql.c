
#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "shapefile_src/shapefil.h"

int main(int argc, char **argv)
{
  if (argc == 1) { printf("usage: shapefile_to_mysqldump [FILENAME]\n"); exit(1); }
  
  setlocale(LC_CTYPE, "en_CA.UTF-8");
  
  char file_name[150];
  sprintf(file_name, "%s", argv[1]);
    
  DBFHandle d = DBFOpen(file_name, "rb");
  if (d == NULL)
  {
    sprintf(file_name, "%s/%s", argv[1], argv[1]);
    d = DBFOpen(file_name, "rb");
    if (d == NULL)
    {
      printf("DBFOpen error (%s.dbf)\n", argv[1]);
      exit(1);
    }
  }
	
	SHPHandle h = SHPOpen(file_name, "rb");
  if (h == NULL)
  {
    printf("SHPOpen error (%s.dbf)\n", argv[1]);
    exit(1);
  }
	
  char filename[60];
  sprintf(filename, "%s.sql", argv[1]);
  printf("%s\n", filename);
  FILE *fp = fopen(filename, "w");
  if (fp == NULL) { printf("fopen error\n"); exit(1); }
	
  int nRecordCount = DBFGetRecordCount(d);
  int nFieldCount = DBFGetFieldCount(d);
  printf("DBF has %d records (with %d fields)\n", nRecordCount, nFieldCount);
	
  fprintf(fp, "SET CHARSET UTF8;\n");
  fprintf(fp, "DROP TABLE IF EXISTS DBF;\n");
  fprintf(fp, "CREATE TABLE DBF (dbf_id MEDIUMINT primary key auto_increment");
  for (int i = 0 ; i < nFieldCount ; i++)
  {
    char pszFieldName[12];
    int pnWidth;
    int pnDecimals;
    DBFFieldType ft = DBFGetFieldInfo(d, i, pszFieldName, &pnWidth, &pnDecimals);
    switch (ft)
    {
      case FTString:
        fprintf(fp, ", %s VARCHAR(%d)", pszFieldName, pnWidth);
        break;
      case FTInteger:
        fprintf(fp, ", %s MEDIUMINT", pszFieldName);
        break;
      case FTDouble:
        fprintf(fp, ", %s DOUBLE(18,15)", pszFieldName);
        break;
      case FTLogical:
        break;
      case FTInvalid:
        break;
    }
  }
  fprintf(fp, ");\n");
  
  for (int i = 0 ; i < nRecordCount ; i++)
  {
    unsigned int k;
    char *cStr;
    char pszFieldName[12];
    int pnWidth;
    int pnDecimals;
    fprintf(fp, "INSERT INTO DBF VALUES (''");
    for (int j = 0 ; j < nFieldCount ; j++)
    {
      DBFFieldType ft = DBFGetFieldInfo(d, j, pszFieldName, &pnWidth, &pnDecimals);
      switch (ft)
      {
        case FTString:
          cStr = (char *)DBFReadStringAttribute(d, i, j);
          for (k = 0 ; k < strlen(cStr) ; k++)
            if (cStr[k] == '"')
              cStr[k] = '\'';
          fprintf(fp, ",\"%s\"", cStr);
          break;
        case FTInteger:
          fprintf(fp, ",\"%d\"", DBFReadIntegerAttribute(d, i, j));
          break;
        case FTDouble:
          fprintf(fp, ",\"%3.15lf\"", DBFReadDoubleAttribute(d, i, j));
          break;
        case FTLogical:
          break;
        case FTInvalid:
          break;
      }
    }
    fprintf(fp, ");\n");
  }
	
  int nShapeType;
  int nEntities;
  const char *pszPlus;
  double adfMinBound[4], adfMaxBound[4];
	
  SHPGetInfo(h, &nEntities, &nShapeType, adfMinBound, adfMaxBound);
  printf("SHP has %d entities\n", nEntities);
  
  fprintf(fp, "DROP TABLE IF EXISTS shape_points;\n");
  fprintf(fp, "CREATE TABLE shape_points (id MEDIUMINTPRIMARY KEY AUTO_INCREMENT, dbf_id MEDIUMINT, part_id MEDIUMINT, x DOUBLE(18,15), y DOUBLE(18,15));\n");
  fprintf(fp, "DROP TABLE IF EXISTS edges;\n");
  fprintf(fp, "CREATE TABLE edges (id MEDIUMINTPRIMARY KEY AUTO_INCREMENT, dbf_id MEDIUMINT, part_id INT, part_type VARCHAR(50));\n");
  fprintf(fp, "ALTER TABLE shape_points ADD KEY dbf_id (dbf_id);\n");
  for (int i = 0; i < nEntities; i++)
  {
    SHPObject	*psShape = SHPReadObject(h, i);
    
    for (int j = 0, iPart = 1; j < psShape->nVertices; j++)
    {
      const char *pszPartType = "";
      
      if (j == 0 && psShape->nParts > 0)
      {
        pszPartType = SHPPartTypeName(psShape->panPartType[0]);
        fprintf(fp, "INSERT INTO edges (dbf_id, part_id, part_type) VALUES (%d, %d, \"%s\");\n", i+1, iPart, pszPartType);
      }
      if (iPart < psShape->nParts && psShape->panPartStart[iPart] == j)
      {
        pszPartType = SHPPartTypeName(psShape->panPartType[iPart]);
        iPart++;
        pszPlus = "+";
        fprintf(fp, "INSERT INTO edges (dbf_id, part_id, part_type) VALUES (%d, %d, \"%s\");\n", i+1, iPart, pszPartType);
      }
      else
        pszPlus = " ";
    }
  
    for (int j = 0, iPart = 1; j < psShape->nVertices; j++)
    {
      const char *pszPartType = "";
      
      if (j == 0 && psShape->nParts > 0) pszPartType = SHPPartTypeName(psShape->panPartType[0]);
      if (iPart < psShape->nParts && psShape->panPartStart[iPart] == j)
      {
        pszPartType = SHPPartTypeName(psShape->panPartType[iPart]);
        iPart++;
        pszPlus = "+";
      }
      else
        pszPlus = " ";
      
      if (j%500==0)
        fprintf(fp, "%sINSERT INTO shape_points (dbf_id, part_id, x, y) VALUES (", (j!=0 ? ");\n": ""));
      else
        fprintf(fp, "),(");
      
      fprintf(fp, "%d, %d, %3.15lf, %3.15lf", i+1, iPart, psShape->padfX[j], psShape->padfY[j]);
    }
    fprintf(fp, ");\n");
    
    SHPDestroyObject(psShape);
  }
  
  
	printf("all done\n");
	if (h != NULL) SHPClose(h);
	if (d != NULL) DBFClose(d);
}